Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, "79834970872-dchs42oupidlep22vf39s0lcdk0uv1dc.apps.googleusercontent.com
", "NBwr01IaHgWWCNMhm3vPaG7f", { :scope => ENV['GOOGLE_SCOPE'], :approval_prompt => "auto"}
end

#:approval_prompt => "auto"