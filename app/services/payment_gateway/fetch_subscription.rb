module PaymentGateway
  class FetchSubscription
    def initialize(user)
      @user = user
    end

    def call
      return unless user.stripe_subscription_id?
      customer = user.payment_customer
      raise "Don't have a customer" unless customer.present?

      Stripe::Subscription.retrieve(current_user.stripe_subscription_id)
    end

    private

    attr_reader :user
  end
end
