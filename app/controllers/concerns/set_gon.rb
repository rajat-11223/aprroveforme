module SetGon
  extend ActiveSupport::Concern

  included do
    before_action :setup_gon
  end

  private

  def setup_gon
    gon.push googleAppId: ENV.fetch("APP_ID"),
             googleUserToken: current_user.try(:token),
             stripePublishableKey: ENV.fetch("STRIPE_PUBLISHABLE_KEY")
  end
end
