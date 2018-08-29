# frozen_string_literal: true

require_relative "production.rb"

return
Workflow::Application.configure do
  config.middleware.use ::Rack::Auth::Basic do |username, password|
    [username, password] == ["approveforme", "2018"]
  end
end
