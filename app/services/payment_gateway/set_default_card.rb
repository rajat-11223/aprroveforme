module PaymentGateway
  class SetDefaultCard
    def initialize(user)
      @user = user
    end

    def call(token:)
      customer = user.payment_customer
      raise "Don't have a customer" unless customer.present?
      raise "Didn't provide token" unless token.present?

      customer.default_source = token
      customer.save
    end

    private

    attr_reader :user
  end
end
