class CheckForCompleteApprovalJob < ApplicationJob
  def perform(approval)
    checker = Approval::StatusChecker.new(approval)
    return unless checker.should_be_completed?

    approval.mark_as_complete!
    UserMailer.completed_approval(approval).deliver_later
  end
end
