class Approver < ApplicationRecord
  belongs_to :approval, inverse_of: :approvers
  before_save { |approver| approver.email = approver.email.downcase }

  include ActionView::Helpers::DateHelper
  include CreationDateScopes

  validates_presence_of :name
  validates_presence_of :email

  def to_s
    string = "Your approval is #{self.required}. ".humanize
    string << self.approval.deadline_in_words
  end

  def generate_code
    self.code = SecureRandom.alphanumeric(50)
  end

  scope :for_email, -> (*emails) do
    emails = Array(emails).compact.map(&:downcase)
    return Approver.none if emails.empty?
    result = all
    emails.each.with_index do |email, index|
      result =
        if index.zero?
          result.where(email: email)
        else
          result.or(Approver.where(email: email))
        end
    end
    result
  end

  scope :by_user, -> (user) { for_email(*user.all_emails) }

  scope :required, -> { where(required: "Required") }
  scope :optional, -> { where(required: "Optional") }

  scope :approved, -> { where(status: "Approved") }
  scope :declined, -> { where(status: "Declined") }
  scope :pending, -> { where(status: "").or(Approver.where(status: "Pending")) }
  scope :approved_or_declined, -> { approved.or(Approver.declined) }

  def has_responded?
    ["Approved", "Declined"].include? self.status
  end
end
