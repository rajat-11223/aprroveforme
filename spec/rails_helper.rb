# This file is copied to spec/ when you run 'rails generate rspec:install'
require "rails_helper"
ENV["RAILS_ENV"] ||= "test"
require File.expand_path("../../config/environment", __FILE__)
# Prevent database truncation if the environment is production
abort("The Rails environment is running in production mode!") if Rails.env.production? || Rails.env.staging?
require "rspec/rails"

# Add additional requires below this line. Rails is not loaded until this point!

# Requires supporting ruby files with custom matchers and macros, etc, in
# spec/support/ and its subdirectories. Files matching `spec/**/*_spec.rb` are
# run as spec files by default. This means that files in spec/support that end
# in _spec.rb will both be required and run as specs, causing the specs to be
# run twice. It is recommended that you do not name files matching this glob to
# end with _spec.rb. You can configure this pattern with the --pattern
# option on the command line or in ~/.rspec, .rspec or `.rspec-local`.
#
# The following line is provided for convenience purposes. It has the downside
# of increasing the boot-up time by auto-requiring all files in the support
# directory. Alternatively, in the individual `*_spec.rb` files, manually
# require only the support files necessary.
#
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# Checks for pending migrations and applies them before tests are run.
# If you are not using ActiveRecord, you can remove this line.
ActiveRecord::Migration.maintain_test_schema!

RSpec.configure do |config|
  config.include ActiveSupport::Testing::TimeHelpers
  config.include FactoryBot::Syntax::Methods
  config.include OmniauthHelpers, type: :system
  config.include CapybaraHelpers, type: :system, js: true
  config.include StripeHelpers, type: :system, js: true
  config.include ActiveSupport::Testing::TimeHelpers

  config.around :each do |ex|
    ex.run_with_retry retry: 3
  end

  config.before(:each, type: :system) do
    Capybara.default_max_wait_time = 10
    mock_omniauth_provider!
    driven_by :rack_test
  end

  config.after(:each, type: :system) do
    cleanup_omniauth!(provider: :default)
    cleanup_omniauth!(provider: :google_oauth2)
  end

  config.around(:each) do |example|
    skip "ignored on CI" if example.metadata[:ci_ignore] && Workflow::Application::RUNNING_ON_CI

    example.run
  end

  Capybara.server = :puma, { Silent: true }

  Capybara.register_driver :chrome do |app|
    Capybara::Selenium::Driver.new(app, browser: :chrome)
  end

  Capybara.register_driver :headless_chrome do |app|
    capabilities = Selenium::WebDriver::Remote::Capabilities.chrome(
      "goog:chromeOptions": {
        args: %w(no-sandbox headless disable-gpu window-size=1280,800),
      },
    )

    Capybara::Selenium::Driver.new(app,
                                   browser: :chrome,
                                   desired_capabilities: capabilities).tap do |d|
      d.browser.download_path = Rails.root.join("tmp/downloads")
    end
  end

  ENGINE = ENV["WITHOUT_HEADLESS"].present? ? :chrome : :headless_chrome
  config.before(:each, type: :system) do
    driven_by ENGINE
  end

  # Remove this line if you're not using ActiveRecord or ActiveRecord fixtures
  config.fixture_path = "#{::Rails.root}/spec/fixtures"

  # If you're not using ActiveRecord, or you'd prefer not to run each of your
  # examples within a transaction, remove the following line or assign false
  # instead of true.
  config.use_transactional_fixtures = true

  # RSpec Rails can automatically mix in different behaviours to your tests
  # based on their file location, for example enabling you to call `get` and
  # `post` in specs under `spec/controllers`.
  #
  # You can disable this behaviour by removing the line below, and instead
  # explicitly tag your specs with their type, e.g.:
  #
  #     RSpec.describe UsersController, :type => :controller do
  #       # ...
  #     end
  #
  # The different available types are documented in the features, such as in
  # https://relishapp.com/rspec/rspec-rails/docs
  config.infer_spec_type_from_file_location!

  # Filter lines from Rails gems in backtraces.
  config.filter_rails_from_backtrace!
  # arbitrary gems may also be filtered via:
  # config.filter_gems_from_backtrace("gem name")
end

RSpec::Sidekiq.configure do |config|
  config.warn_when_jobs_not_processed_by_sidekiq = false
end
