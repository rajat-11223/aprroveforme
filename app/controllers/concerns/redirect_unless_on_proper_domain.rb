module RedirectUnlessOnProperDomain
  extend ActiveSupport::Concern

  included do
    before_action :redirect_to_app_domain
  end

  def redirect_to_app_domain
    return unless Rails.env.production? || Rails.env.staging?
    redirect_to(Workflow::Application::APP_HOST, status: :moved_permanently) unless request.host_with_port.include?(Workflow::Application::APP_DOMAIN)
  end
end
