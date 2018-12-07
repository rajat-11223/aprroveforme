
class StatusMailerPreview < ActionMailer::Preview
  def update
    user = User.find_by(email: "ricky@rakefire.io")
    EmailFlow::StatusMailer.update(user)
  end
end
