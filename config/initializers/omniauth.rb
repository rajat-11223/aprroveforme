Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, ENV['GOOGLE_ID'], ENV['GOOGLE_SECRET'], { :scope => ENV['GOOGLE_SCOPE'], :approval_prompt => "auto"}
end

#:approval_prompt => "auto"