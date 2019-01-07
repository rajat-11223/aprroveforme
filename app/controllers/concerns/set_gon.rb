module SetGon
  extend ActiveSupport::Concern

  included do
    before_action :setup_gon
  end

  private

  def setup_gon
    current_user.try(:refresh_google_auth!)

    # non-watched vars
    gon.global.googleAppId = ENV.fetch("APP_ID")
    gon.global.stripePublishableKey = ENV.fetch("STRIPE_PUBLISHABLE_KEY")

    # watched vars
    gon.watch.googleUserToken = current_user.try(:token)
    gon.watch.googleUserTokenExpiresAt = current_user.try(:expires_at)
  end
end
