# frozen_string_literal: true

require_relative "production.rb"

# Set the domain to explecitly be our BASE_APP_DOMAIN
# https://github.com/omniauth/omniauth-oauth2/issues/58
Rails.application.config.session_store :cookie_store, key: "_approveforme_session", domain: Workflow::Application::BASE_APP_DOMAIN, expire_after: 55.minutes

ActionMailer::Base.delivery_method = :smtp
ActionMailer::Base.smtp_settings = {
  user_name: "0644e1881fb7c3",
  password: "77b1fc73ce2060",
  address: "smtp.mailtrap.io",
  domain: "smtp.mailtrap.io",
  port: "2525",
  authentication: :cram_md5,
}
