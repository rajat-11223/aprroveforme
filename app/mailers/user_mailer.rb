class UserMailer < ActionMailer::Base
  default from: "\"ApproveForMe\" <Team@ApproveForMe.com>"
  # mail sent when a user signs up for the service
    def new_user(name, email)
      @name = name
      @email = email
      mail(to: @email, subject: "Welcome to ApproveForMe!")
    end

  # mail sent to creator of a new approval
  def my_new_approval(approval)
    @approval = approval
    @owner = @approval.owner_user
    @name = @owner.name
    @email = @owner.email
    @subject = @approval.title + " has been sent out for approval."
    mail(to: @email, subject: @subject)
  end

  # mail sent to approvers of a new approval
  def new_approval_invite(approval, approver)
    @approval = approval
    @owner = @approval.owner_user
    @subject = @owner.name + " has requested your approval on " + @approval.title
    @approver = approver
    @email = @approver.email
    mail(to: @email, subject: @subject, reply_to: @owner.email)
  end


  # mail sent whenever an approver responds
  def approval_update(approver)
    @approver = approver
    @approval = @approver.approval
    @owner = @approval.owner_user
    @subject = @approver.name + " has responded to " + @approval.title
    mail(to: @owner.email, subject: @subject)
  end

  # mail sent when an approval is 100%
  def completed_approval(approval)
    @approval = approval
    @owner = @approval.owner_user
    @subject = @approval.title + " has been signed off!"
    mail(to: @owner.email, subject: @subject)
  end
end
