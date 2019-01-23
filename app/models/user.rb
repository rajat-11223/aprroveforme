# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  activated_at              :datetime
#  approvals_received        :integer
#  approvals_received_30     :integer
#  approvals_responded_to    :integer
#  approvals_responded_to_30 :integer
#  approvals_sent            :integer
#  approvals_sent_30         :integer
#  code                      :string(255)
#  email                     :string(255)
#  email_domain              :string(255)
#  expires                   :boolean
#  expires_at                :datetime
#  first_name                :string(255)
#  last_login_at             :datetime
#  last_name                 :string(255)
#  last_sent_date            :datetime
#  name                      :string(255)
#  picture                   :string(255)
#  provider                  :string(255)
#  refresh_token             :string(255)
#  second_email              :string(255)
#  time_zone                 :string
#  token                     :string(255)
#  uid                       :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  customer_id               :string
#  stripe_subscription_id    :string
#

require "google/api_client/client_secrets"

class User < ApplicationRecord
  rolify
  validates :email, :picture, presence: true
  validates_format_of :email, :with => /\A(.*)@(.*)\.(.*)\Z/
  before_save { |user| user.email = user.email.downcase }

  has_many :approvals, dependent: :destroy, foreign_key: :owner
  has_one :subscription, autosave: true, required: false, class_name: "SubscriptionHistory"
  has_many :subscription_histories, dependent: :destroy

  scope :activated, -> { where.not(activated_at: nil) }
  scope :not_activated, -> { where(activated_at: nil) }

  def ability
    @ability ||= Ability.new(self)
  end

  def google_auth
    # Create a new google secrets client
    @google_auth_client ||=
      Google::APIClient::ClientSecrets.new(
        {
          "web" => {
            "client_id" => ENV["GOOGLE_ID"],
            "client_secret" => ENV["GOOGLE_SECRET"],
            "access_token" => self.try(:token),
            "refresh_token" => self.try(:refresh_token),
            "expires_at" => self.try(:expires_at).try(:to_i),
          },
        }
      )
  end

  def refresh_google_auth!(force: false)
    if token_needs_refreshed? || force
      # continue on
    else
      return false
    end

    authorization = google_auth.to_authorization
    response = authorization.refresh!

    return false if response.blank?

    self.token = response["access_token"]
    self.expires_at = Time.zone.now + response["expires_in"].seconds
    self.save!

    reset_google_auth!
    true
  end

  def payment_customer
    return unless customer_id.to_s.start_with?("cus_")

    @payment_customer ||= Stripe::Customer.retrieve(self.customer_id)
  end

  def payment_customer?
    !!payment_customer
  end

  def paid?
    subscription? &&
      (subscription.professional? || subscription.unlimited?)
  end

  def not_paid?
    !paid?
  end

  def subscription?
    subscription.present?
  end

  def self.to_csv(output = "")
    output << CSV.generate_line(self.column_names)

    self.find_each.lazy.each do |user, _index|
      line = CSV.generate_line(user.attributes.values_at(*column_names))
      output << line
    end

    output
  end

  def activated?
    activated_at.present? && self.activated_at <= Time.zone.now
  end

  def activate!
    update_attributes(activated_at: Time.now)
  end

  private

  def token_needs_refreshed?
    !(self.refresh_token.blank? || self.expires_at.blank? || Time.zone.now < (self.expires_at - 10.minutes))
  end

  def reset_google_auth!
    @google_auth_client = nil
  end
end
