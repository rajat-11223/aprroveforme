module PaymentGateway
  class SyncCustomer
    def initialize(user)
      @user = user
    end

    def call
      raise "We don't have a customer yet" unless user.payment_customer?

      user.payment_customer.tap do |customer|
        customer.email = user.email
        customer.description = user.name

        customer.save
      end
    end

    private

    attr_reader :user
  end
end
