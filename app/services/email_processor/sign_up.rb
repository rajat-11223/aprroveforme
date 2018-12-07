class EmailProcessor
  class SignUp < Base
    triggered_by :signup, :sign_up

    def process
      return if EmailProcessor::SignUpChecker::CHECK.call(from_email)
      puts "-> signing up"

      raise StopProcessing, "not yet implemented"
    end
  end
end
