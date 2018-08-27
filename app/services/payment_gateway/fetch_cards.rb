module PaymentGateway
  class FetchCards
    def initialize(user)
      @user = user
    end

    def call
      customer = user.payment_customer
      raise "Don't have a customer" unless customer.present?

      customer.sources.data
    end

    private

    attr_reader :user
  end
end
