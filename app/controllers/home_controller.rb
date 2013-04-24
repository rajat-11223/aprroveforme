class HomeController < ApplicationController
  def index
    if current_user
        current_user.google_auth
    	@my_approvals = Approval.where("owner = ? and deadline > ?", current_user.id, Date.today+1)
    	@my_completed_approvals = Approval.where("owner = ? and deadline < ?", current_user.id, Date.today+1)
    	@pending_approvals = Approver.where("email = ? and status = ?", current_user.email, "Pending")
    	@signedoff_approvals = Approver.where("email = ? and status != ?", current_user.email, "Pending")
    	@any_approvals = Approval.where("owner = ?", current_user.id)
    	@any_approvers = Approver.where("email = ?", current_user.email)
    end
  end
end
