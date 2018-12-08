module EmailFlow
  class SignupMailer < EmailFlowMailer
    def signup(email)
      @email = email
      mail(to: @email, subject: "ApproveForMe Signup")
    end

    def how_to_signup(email)
      @email = email
      mail(to: @email, subject: "ApproveForMe How To Signup")
    end
  end
end
