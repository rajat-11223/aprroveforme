class User < ActiveRecord::Base
  rolify
  attr_accessible :role_ids, :as => :admin
  attr_accessible :provider, :uid, :name, :email, :picture, :token, :first_name, :last_name, :code, :second_email
  validates :email, :picture, :presence => true
  before_save { |user| user.email = user.email.downcase }

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
      UserMailer.delay.new_user(user.name, user.email)
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

end
