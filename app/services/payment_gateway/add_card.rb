module PaymentGateway
  class AddCard
    def initialize(user)
      @user = user
    end

    def call(source:)
      customer = user.payment_customer
      raise "Don't have a customer" unless customer.present?
      raise "Didn't provide source" unless source.present?

      customer.sources.create({ source: source })
    end

    private

    attr_reader :user
  end
end
