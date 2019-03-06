class WelcomeMailer < ActionMailer::Base
  include ActionView::Helpers::SanitizeHelper
  default from: "\"ApproveForMe\" <team@approveforme.com>"
  layout "layouts/email_flow"

  def new_user(user:)
    @user = user
    mail(to: @user.email, subject: "[AFM] Welcome to ApproveForMe")
  end

  def day_one(user:)
    @user = user
    mail(to: @user.email, subject: "[AFM] #{@user.name}, Never think about document approvals again")
  end

  def day_three(user:)
    @user = user
    mail(to: @user.email, subject: "[AFM] Be the approval hero")
  end

  def day_seven(user:)
    @user = user
    mail(to: @user.email, subject: "[AFM] #{@user.name}, Feedback is just an approval in disguise")
  end
end
