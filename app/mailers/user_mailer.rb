class UserMailer < ActionMailer::Base
  default from: "\"ApproverForMe\" <Team@ApproveForMe.com>"

  def new_user(name, email)
    @name = name
    @email = email
    mail(:to => @email, :subject => "Welcome to ApproveForMe!")
  end

end
