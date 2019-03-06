
class WelcomeMailerPreview < ActionMailer::Preview
  # mail sent when a user signs up for the service
  def new_user
    WelcomeMailer.new_user(user: FactoryBot.build_stubbed(:user, activated_at: nil))
  end

  def day_one
    WelcomeMailer.day_one(user: user)
  end

  def day_three
    WelcomeMailer.day_three(user: user)
  end

  def day_seven
    WelcomeMailer.day_seven(user: user)
  end

  private

  def user
    @user ||= FactoryBot.build_stubbed(:user, :with_changing_activation)
  end
end
