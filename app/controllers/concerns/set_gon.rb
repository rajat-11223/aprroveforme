module SetGon
  extend ActiveSupport::Concern

  included do
    before_action :setup_gon
  end

  private

  def setup_gon
    current_user.try(:refresh_google_auth!)

    gon.push googleAppId: ENV.fetch("APP_ID"),
             googleUserToken: current_user.try(:token),
             googleUserTokenExpiresAt: current_user.try(:expires_at),
             stripePublishableKey: ENV.fetch("STRIPE_PUBLISHABLE_KEY")
  end
end
