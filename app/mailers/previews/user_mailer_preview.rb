
class UserMailerPreview < ActionMailer::Preview
  # mail sent when a user signs up for the service
  def new_user
    UserMailer.new_user(user.name, user.email)
  end

  # # mail sent to creator of a new approval
  def my_new_approval
    UserMailer.my_new_approval(approval)
  end

  # mail sent to approvers of a new approval
  def new_approval_invite
    UserMailer.new_approval_invite(approval, approver)
  end

  # mail sent whenever an approver responds
  def approval_update
    UserMailer.approval_update(approver)
  end

  # mail sent when an approval is 100%
  def completed_approval
    UserMailer.completed_approval(approval)
  end

  private

  def approval
    @approval ||= Approval.first
  end

  def approver
    @approver ||= approval.approvers.first
  end

  def user
    @user ||= approval.user
  end
end
