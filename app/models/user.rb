class User < ActiveRecord::Base
  rolify
  attr_accessible :role_ids, :as => :admin
  attr_accessible :provider, :uid, :name, :email, :picture, :token, :first_name, :last_name, :code

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
         user.name = auth['info']['name'] || ""
         user.email = auth['info']['email'] || ""
         user.picture = auth['info']['image'] || ""
         user.first_name = auth['info']['first_name'] || ""
         user.last_name = auth['info']['last_name'] || ""
      end
      UserMailer.delay.new_user(user.name, user.email)
    end
  end

  def google_auth
    
    # Create a new API client & load the Google Drive API 
    client = Google::APIClient.new
    client.authorization.client_id = ENV['GOOGLE_ID']
    client.authorization.client_secret = ENV['GOOGLE_SECRET']
    client.authorization.scope = 'https://www.googleapis.com/auth/drive.file https://docs.google.com/feeds/ https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/userinfo.profile'
    client.authorization.redirect_uri = ENV['REDIRECT_URI']
    drive = client.discovered_api('drive', 'v2')
    client.authorization.code = self.code.chomp
    client.authorization.access_token = self.token
    client.authorization.refresh_token = self.refresh_token

  
   # result = client.execute!(
   #   :api_method => drive.files.list,
   #   :parameters => {})
   # if result.status == 200
   #     puts "success!"
   #     jj result.data.to_hash
   # else
   #     puts "An error occurred: #{result.data['error']['message']}"
   #     page_token = nil
   # end
  
  end

end
