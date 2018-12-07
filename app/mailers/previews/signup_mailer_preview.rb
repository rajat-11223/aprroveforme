
class SignupMailerPreview < ActionMailer::Preview
  def how_to_signup
    EmailFlow::SignupMailer.how_to_signup("random.email@gmail.com")
  end
end
