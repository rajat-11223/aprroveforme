class User < ApplicationRecord
  rolify
  validates :email, :picture, presence: true
  validates_format_of :email, :with => /\A(.*)@(.*)\.(.*)\Z/
  before_save { |user| user.email = user.email.downcase }

  has_many :approvals, dependent: :destroy, foreign_key: :owner
  has_one :subscription, autosave: true, required: false, class_name: "SubscriptionHistory"
  has_many :subscription_histories, dependent: :destroy

  def ability
    @ability ||= Ability.new(self)
  end

  def google_auth
    @google_auth_client ||= begin
      # Create a new API client & load the Google Drive API
      client = GoogleApiWrapper.new
      client.authorization.client_id = ENV["GOOGLE_ID"]
      client.authorization.client_secret = ENV["GOOGLE_SECRET"]
      client.authorization.scope = ENV["GOOGLE_SCOPE"]
      client.authorization.redirect_uri = ENV["REDIRECT_URI"]
      client.authorization.code = self.code.chomp || ""
      client.authorization.access_token = self.token
      client.authorization.refresh_token = self.refresh_token

      if client.authorization.refresh_token && client.authorization.expired?
        client.authorization.fetch_access_token!
      end

      client
    end
  end

  def refresh_google
    # TODO: Move this into a service
    connection = Faraday.new("https://www.googleapis.com/oauth2/v4/token") do |conn|
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
    end

    response = connection.post do |req|
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"
      req.body = URI.encode_www_form({client_id: ENV["GOOGLE_ID"],
                                      client_secret: ENV["GOOGLE_SECRET"],
                                      refresh_token: self.refresh_token,
                                      grant_type: "refresh_token"})
    end

    if response.status == 200
      self.update_attributes token: response.body["access_token"]
    else
      Rails.logger.error("Unable to refresh google_oauth2 authentication token for User(id=#{self.id}).")
      Rails.logger.error("Refresh token response body: #{response.body}")
    end
  end

  def payment_customer
    return unless customer_id.to_s.start_with?("cus_")

    @payment_customer ||= Stripe::Customer.retrieve(self.customer_id)
  end

  def payment_customer?
    !!payment_customer
  end

  def self.to_csv(output = "")
    output << CSV.generate_line(self.column_names)

    self.find_each.lazy.each do |user, _index|
      line = CSV.generate_line(user.attributes.values_at(*column_names))
      output << line
    end

    output
  end
end
