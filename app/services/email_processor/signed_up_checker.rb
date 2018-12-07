class EmailProcessor
  class SignedUpChecker < Base
    triggered_by :any

    CHECK = -> (email) { User.exists?(email: email) }

    def process
      return if CHECK.call(from_email)

      EmailFlow::SignupMailer.how_to_signup(from_email).deliver_later

      raise StopProcessing, "The email address is not signed up, so let's stop now"
    end
  end
end
