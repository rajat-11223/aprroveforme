class HomeController < ApplicationController
  def index
    if current_user
    	@my_approvals = Approval.where("owner = ? and deadline >= ?", current_user.id, Date.today+1)
    	@my_completed_approvals = Approval.where("owner = ? and deadline < ?", current_user.id, Date.today+1)
    	@pending_approvals = Approver.where("(email = ? or email = ? ) and (status = ? or status = ?)", current_user.email, current_user.second_email, "Pending", "")
    	@signedoff_approvals = Approver.where("(email = ? or email = ? ) and (status = ? or status = ?)", current_user.email, current_user.second_email, "Approved", "Declined")
    	@any_approvals = Approval.where("owner = ?", current_user.id)
    	@any_approvers = Approver.where("email = ? or email = ? ", current_user.email, current_user.second_email)
    end
  end
end
