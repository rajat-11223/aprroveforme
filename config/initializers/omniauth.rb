Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_ID'], ENV['GOOGLE_SECRET'], { :scope => 'https://www.googleapis.com/auth/drive.file https://docs.google.com/feeds/ https://www.googleapis.com/auth/drive https://www.googleapis.com/auth/userinfo.profile' }
end
