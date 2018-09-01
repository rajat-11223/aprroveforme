class User < ApplicationRecord
  rolify
  validates :email, :picture, presence: true
  before_save { |user| user.email = user.email.downcase }

  has_many :approvals, dependent: :destroy, foreign_key: :owner
  has_one :payment_method, dependent: :destroy
  has_one :subscription, autosave: true, required: false, class_name: 'SubscriptionHistory'
  has_many :subscription_histories, dependent: :destroy

  def ability
    @ability ||= Ability.new(self)
  end

  def all_emails
    [email, second_email].compact
  end

  def google_auth
    # Create a new API client & load the Google Drive API
    client = GoogleApiWrapper.new
    client.authorization.client_id = ENV['GOOGLE_ID']
    client.authorization.client_secret = ENV['GOOGLE_SECRET']
    client.authorization.scope = ENV['GOOGLE_SCOPE']
    client.authorization.redirect_uri = ENV['REDIRECT_URI']
    client.authorization.code = self.code.chomp || ""
    client.authorization.access_token = self.token
    client.authorization.refresh_token = self.refresh_token

    if client.authorization.refresh_token && client.authorization.expired?
      client.authorization.fetch_access_token!
    end

    client
  end

  def refresh_google
    # TODO: Move this into a service
    connection = Faraday.new('https://accounts.google.com/o/oauth2/token') do |conn|
      conn.response :json, :content_type => /\bjson$/
      conn.adapter Faraday.default_adapter
    end

    response = connection.post do |req|
      req.headers['Content-Type'] = 'application/x-www-form-urlencoded'
      req.body = { client_id: ENV['GOOGLE_ID'],
                   client_secret: ENV['GOOGLE_SECRET'],
                   refresh_token: self.refresh_token,
                   grant_type: 'refresh_token'
                 }.to_json
    end

    if response.status == 200
      self.update_attributes token: response.body['access_token']
      self.save
    else
      Rails.logger.error("Unable to refresh google_oauth2 authentication token.")
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

  # def view_docs
  #   client = self.google_auth
  #   drive = client.discovered_api('drive', 'v2')
  #   page_token = nil
  #   doc_list = []
  #
  #   # params
  #   search_string = "title contains 'WhichBus'"
  #
  #   begin
  #     if page_token.to_s != ''
  #       parameters['pageToken'] = page_token
  #     end
  #
  #     result = drive.list_files(q: search_string)
  #
  #     if result.status == 200
  #         puts "success!"
  #         files = result.data
  #         #doc_list << files.items
  #         files.items.each {|file| doc_list << file}
  #         page_token = files.next_page_token
  #     else
  #         puts "An error occurred: #{result.data['error']['message']}"
  #         page_token = nil
  #     end
  #   end while page_token.to_s != ''
  #
  #   doc_list
  # end

  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << column_names

      User.all.find_each.lazy do |user|
        csv << user.attributes.values_at(*column_names)
      end
    end
  end
end
