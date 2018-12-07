module EmailFlow
  class SignupMailer < EmailFlowMailer
    def how_to_signup(email)
      @email = email
      mail(to: @email, subject: "ApproveForMe Signup")
    end
  end
end
