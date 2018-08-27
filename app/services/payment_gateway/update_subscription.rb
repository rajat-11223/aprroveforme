module PaymentGateway
  class UpdateSubscription
    def initialize(user)
      @user = user
    end

    def call(name:, interval:)
      customer = user.payment_customer
      identifier = Plans::List[name.to_s].dig(interval.to_s, "identifier")
      subscription = customer.subscriptions.first

      raise "Unknown plan #{name} - #{interval}" unless identifier.present?
      raise "Don't have a customer" unless customer.present?
      raise "Don't have a subscription" unless subscription.present?

      User.transaction do
        subscription.plan = identifier
        subscription.billing = "charge_automatically"
        subscription.prorate = true
        subscription.save

        user.update_attributes! stripe_subscription_id: subscription.id

        user.subscription_histories.create! plan_name: name,
                                            plan_interval: interval,
                                            plan_identifier: identifier,
                                            subscription_identifier: subscription.id,
                                            plan_date: Time.now
      end
    end

    private

    attr_reader :user
  end
end
