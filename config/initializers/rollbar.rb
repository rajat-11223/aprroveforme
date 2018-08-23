require 'rollbar'

Rollbar.configure do |config|
  config.enabled = Rails.env.production?
  config.access_token = ENV.fetch("ROLLBAR_ACCESS_TOKEN")
end
