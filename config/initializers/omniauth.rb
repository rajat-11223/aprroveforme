Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2, "79834970872-0i16kifmu100tf9af5orbqg8fm30o7ke.apps.googleusercontent.com
", "Xs-PuaCjK6iAtuLRUzj3f0NY", {  :approval_prompt => "auto"}
end

#:approval_prompt => "auto"