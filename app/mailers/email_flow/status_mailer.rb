module EmailFlow
  class StatusMailer < EmailFlowMailer
    def update(user)
      @user = user
      mail(to: @user.email, subject: "ApproveForMe Status")
    end
  end
end
