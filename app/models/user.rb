class User < ApplicationRecord
  rolify
  validates :email, :picture, :presence => true
  before_save { |user| user.email = user.email.downcase }

  has_and_belongs_to_many :roles, :join_table => :users_roles
  has_many :approvals, dependent: :destroy
  has_one :subscription, dependent: :destroy
  has_one :payment_method, dependent: :destroy
  has_many :subscription_histories, dependent: :destroy

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
        puts auth.to_s
         user.name = auth['info']['name'] || ""
         user.email = auth['info']['email'] || ""
         user.picture = auth['info']['image'] || "http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(user.email.downcase.strip)}?d=mm"
         user.first_name = auth['info']['first_name'] || ""
         user.last_name = auth['info']['last_name'] || ""
      end
      UserMailer.new_user(user.name, user.email).deliver_later
    end
  end

  def set_second_email(email)
    self.second_email = email
  end


  def google_auth
    # Create a new API client & load the Google Drive API
    client = Google::APIClient.new
    client.authorization.client_id = ENV['GOOGLE_ID']
    client.authorization.client_secret = ENV['GOOGLE_SECRET']
    client.authorization.scope = ENV['GOOGLE_SCOPE']
    client.authorization.redirect_uri = ENV['REDIRECT_URI']
    client.authorization.code = self.code.chomp || ""
    client.authorization.access_token = self.token
    client.authorization.refresh_token = self.refresh_token

    if client.authorization.refresh_token &&
        client.authorization.expired?
        client.authorization.fetch_access_token!
    end
    return client
  end

  def refresh_google
    options = {
      body: {
        client_id: ENV['GOOGLE_ID'],
        client_secret: ENV['GOOGLE_SECRET'],
        refresh_token: self.refresh_token,
        grant_type: 'refresh_token'
      },
      headers: {
        'Content-Type' => 'application/x-www-form-urlencoded'
      }
    }

    @response = HTTParty.post('https://accounts.google.com/o/oauth2/token', options)
    if @response.code == 200
      self.token = @response.parsed_response['access_token']
      self.save
    else
      Rails.logger.error("Unable to refresh google_oauth2 authentication token.")
      Rails.logger.error("Refresh token response body: #{@response.body}")
    end
  end

  def update_stats
    self.email_domain = (self.email.split("@"))[1]
    self.approvals_sent = Approval.where("owner = ?", self.id).count
    self.approvals_received = Approver.where("email = ?", self.email).count
    self.approvals_responded_to = Approver.where("email = ? and status != ? ", self.email, "").count
    self.approvals_sent_30 = Approval.where("owner = ? and created_at > ?", self.id, 30.days.ago ).count
    self.approvals_received_30 = Approver.where("email = ? and created_at > ?", self.email, 30.days.ago).count
    self.approvals_responded_to_30 = Approver.where("email = ? and status != ? and created_at > ?", self.email, "", 30.days.ago).count

    if Approval.where("owner = ?", self.id).last
      self.last_sent_date = Approval.where("owner = ?", self.id).last.created_at
    end

    self.save
  end

  def view_docs
    client = self.google_auth
    drive = client.discovered_api('drive', 'v2')
    page_token = nil
    doc_list = []

    # params
    @string = "title contains 'WhichBus'"

    begin
    if page_token.to_s != ''
      parameters['pageToken'] = page_token
    end
    result = client.execute!(
      :api_method => drive.files.list,
      :parameters => {'q' => @string})
    if result.status == 200
        puts "success!"
        files = result.data
        #doc_list << files.items
        files.items.each {|file| doc_list << file}
        page_token = files.next_page_token
    else
        puts "An error occurred: #{result.data['error']['message']}"
        page_token = nil
    end
    end while page_token.to_s != ''
  doc_list
  end

  def self.to_csv(options = {})
  CSV.generate(options) do |csv|
    csv << column_names
    all.each do |user|
      csv << user.attributes.values_at(*column_names)
    end
  end
end

end
