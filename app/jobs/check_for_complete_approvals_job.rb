class CheckForCompleteApprovalsJob < ApplicationJob
  def perform
    Approval.not_complete.find_each do |approval|
      CheckForCompleteApprovalJob.perform_later(approval)
    end
  end
end
