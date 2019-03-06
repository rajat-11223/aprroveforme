
class WelcomeMailerPreview < ActionMailer::Preview
  # mail sent when a user signs up for the service
  def new_user
    WelcomeMailer.new_user(user: user)
  end

  def one_day
    WelcomeMailer.one_day(user: user)
  end

  def three_day
    WelcomeMailer.three_day(user: user)
  end

  def seven_days
    WelcomeMailer.seven_days(user: user)
  end

  private

  def user
    @user ||= User.first
  end
end
