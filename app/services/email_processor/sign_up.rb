class EmailProcessor
  class SignUp < Base
    triggered_by :signup, :sign_up

    def process
      return if EmailProcessor::SignedUpChecker::CHECK.call(from_email)

      EmailFlow::SignupMailer.signup(from_email).deliver_later

      raise StopProcessing, "SignUp action should stop further processing"
    end
  end
end
