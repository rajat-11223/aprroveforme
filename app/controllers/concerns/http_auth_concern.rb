module HttpAuthConcern
  extend ActiveSupport::Concern
  included do
    before_action :http_authenticate
  end

  def http_authenticate
    return true unless Rails.env.staging?

    authenticate_or_request_with_http_basic do |username, password|
      username == "approveforme" && password == Time.zone.today.year.to_s
    end
  end
end
