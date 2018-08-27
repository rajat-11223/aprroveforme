Rails.application.config.middleware.use OmniAuth::Builder do
    provider :google_oauth2,
      ENV['GOOGLE_ID'],
      ENV['GOOGLE_SECRET'],
      { scope: ENV['GOOGLE_SCOPE'],
        approval_prompt: "consent"}

  OmniAuth.config.on_failure = Proc.new { |env|
    OmniAuth::FailureEndpoint.new(env).redirect_to_failure
  }
end
