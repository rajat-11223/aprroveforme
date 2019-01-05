Rails.application.config.middleware.use OmniAuth::Builder do
  provider :google_oauth2,
           ENV.fetch("GOOGLE_ID"),
           ENV.fetch("GOOGLE_SECRET"),
           {
             "scope" => ENV["GOOGLE_SCOPE"],
             "prompt" => "select_account",
             "access_type" => "offline",
             "skip_jwt" => Rails.env.development?,
           }

  OmniAuth.config.on_failure = Proc.new { |env|
    OmniAuth::FailureEndpoint.new(env).redirect_to_failure
  }
end
