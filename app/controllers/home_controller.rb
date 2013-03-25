class HomeController < ApplicationController
  def index
    if current_user
    	@my_approvals = Approval.where("owner = ?", current_user.id)
    	@pending_approvals = Approver.where("email = ? and status = ?", current_user.email, "Pending")
    end
  end
end
