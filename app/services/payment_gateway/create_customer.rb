module PaymentGateway
  class CreateCustomer
    def initialize(user)
      @user = user
    end

    def call(token = nil)
      raise "Already have customer" if user.customer_id?

      attrs = { email: user.email, description: user.name }
      attrs[:source] = token if token.present?


      User.transaction do
        customer = Stripe::Customer.create(attrs)
        user.update_attributes! customer_id: customer.id

        customer
      end
    end

    private

    attr_reader :user
  end
end
