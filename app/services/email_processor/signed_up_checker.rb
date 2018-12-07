class EmailProcessor
  class SignedUpChecker < Base
    triggered_by :any

    CHECK = -> (email) { return if User.exists?(email: email) }

    def process
      CHECK.call(from_email)

      raise StopProcessing.new("The email address is not signed up")
    end
  end
end
