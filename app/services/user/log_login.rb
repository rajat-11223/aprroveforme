class User
  class LogLogin
    def initialize(user)
      @user = user
    end

    def call
      user.update_attributes last_login_at: Time.now
    end

    private

    attr_reader :user
  end
end
