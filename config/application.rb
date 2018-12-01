require File.expand_path('../boot', __FILE__)

require 'rails/all'
require 'active_support/all'
require 'csv'

Bundler.require(:default, Rails.env)

module Workflow
  class Application < Rails::Application

    APP_HOST = ENV.fetch("APP_HOST")
    APP_DOMAIN = ENV.fetch("APP_DOMAIN")
    BASE_APP_DOMAIN = ENV.fetch("BASE_APP_DOMAIN", APP_DOMAIN)
    ENV["ROLES"] ||= "admin user VIP"
    ENV["GOOGLE_SCOPE"] ||= "https://www.googleapis.com/auth/userinfo.email https://www.googleapis.com/auth/drive.file https://www.googleapis.com/auth/userinfo.profile https://www.googleapis.com/auth/drive.install"

    SENDGRID_API_KEY = ENV.fetch("SENDGRID_API_KEY")
    SENDGRID_CLIENT  = SendGrid::API.new(api_key: SENDGRID_API_KEY).client

    # don't generate RSpec tests for views and helpers
    config.generators do |g|
      g.test_framework :rspec
      g.view_specs false
      g.helper_specs false
    end


    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Custom directories with classes and modules you want to be autoloadable.
    # config.autoload_paths += %W(#{config.root}/extras)
    config.autoload_paths += %W(#{config.root}/lib)


    # Only load the plugins named here, in the order given (default is alphabetical).
    # :all can be used as a placeholder for all plugins not explicitly named.
    # config.plugins = [ :exception_notification, :ssl_requirement, :all ]

    # Activate observers that should always be running.
    # config.active_record.observers = :cacher, :garbage_collector, :forum_observer

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    #config.time_zone = "Pacific Time (US & Canada)"
    #config.active_record.default_timezone = "Pacific Time (US & Canada)"

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Configure the default encoding used in templates for Ruby 1.9.
    config.encoding = "utf-8"

    # Configure sensitive parameters which will be filtered from the log file.
    config.filter_parameters += [:password, :number, :expiration_date, :cvv]

    # Enable escaping HTML in JSON.
    config.active_support.escape_html_entities_in_json = true

    # Use SQL instead of Active Record's schema dumper when creating the database.
    # This is necessary if your schema can't be completely dumped by the schema dumper,
    # like if you have constraints or database-specific column types
    # config.active_record.schema_format = :sql

    # Enforce whitelist mode for mass assignment.
    # This will create an empty whitelist of attributes available for mass-assignment for all models
    # in your app. As such, your models will need to explicitly whitelist or blacklist accessible
    # parameters by using an attr_accessible or attr_protected declaration.
    #config.load_defaults 5.0

    # Enable the asset pipeline
    config.assets.enabled = true
    config.assets.initialize_on_precompile = false

    # ActiveSupport.halt_callback_chains_on_return_false = false

    config.action_mailer.perform_caching = true
    config.action_mailer.deliver_later_queue_name = :mailers
    config.action_controller.forgery_protection_origin_check = true
    config.action_controller.per_form_csrf_tokens = true
    config.active_record.belongs_to_required_by_default = true
    # config.active_record.raise_in_transactional_callbacks = true
    config.i18n.enforce_available_locales = false
    # Version of your assets, change this if you want to expire all your assets
    config.assets.version = '2.0'

    config.google_verification = "google16deb60cae23dff7"
    config.startup_ranking_verification = "startupranking1011604961421011"

    require Rails.root.join("lib/country_block")

    config.middleware.insert_before ActionDispatch::Static, CountryBlock::App
  end
end
