class EmailProcessor
  class SignUp < Base
    triggered_by :signup, :sign_up

    def process
      return if EmailProcessor::SignUpChecker::CHECK.call(from_email)

      raise StopProcessing, "SignUp via email not yet implemented"
    end
  end
end
