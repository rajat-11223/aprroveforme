module PaymentGateway
  class RemoveCard
    def initialize(user)
      @user = user
    end

    def call(token:)
      customer = user.payment_customer
      raise "Don't have a customer" unless customer.present?
      raise "Didn't provide token" unless token.present?

      user.payment_customer.sources.retrieve(token).delete
    end

    private

    attr_reader :user
  end
end
