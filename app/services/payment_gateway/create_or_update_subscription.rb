module PaymentGateway
  class CreateOrUpdateSubscription
    def initialize(user)
      @user = user
    end

    def call(name:, interval:)
      if user.subscription?
        PaymentGateway::UpdateSubscription.new(user).call(name: name,
                                                          interval: interval)
      else
        PaymentGateway::CreateSubscription.new(user).call(name: name,
                                                          interval: interval)
      end
    end

    private

    attr_reader :user
  end
end
