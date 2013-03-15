class HomeController < ApplicationController
  def index
    if current_user
    	@my_approvals = Approval.where("owner = ?", current_user.id)
    	@for_approvals = Approver.where("email = ?", current_user.email)
    end
  end
end
