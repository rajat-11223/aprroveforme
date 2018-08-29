require 'rollbar'

Rollbar.configure do |config|
  config.enabled = Rails.env.production? || Rails.env.staging?
  config.environment = Rails.env
  config.access_token = ENV.fetch("ROLLBAR_ACCESS_TOKEN")
end
