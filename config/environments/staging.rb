# frozen_string_literal: true

require_relative "production.rb"

# Set the domain to explecitly be our BASE_APP_DOMAIN
# https://github.com/omniauth/omniauth-oauth2/issues/58
Workflow::Application.config.session_store :cookie_store, key: '_approveforme_session', domain: Workflow::Application::BASE_APP_DOMAIN

Workflow::Application.configure do
  config.middleware.use ::Rack::Auth::Basic do |username, password|
    [username, password] == ["approveforme", "2018"]
  end
end
