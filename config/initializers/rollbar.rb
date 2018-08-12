return unless Rails.env.production?

require 'rollbar'

Rollbar.configure do |config|
  config.enabled = true
  config.access_token = ENV.fetch("ROLLBAR_ACCESS_TOKEN")
end
