class HomeController < ApplicationController
  def index
    if current_user
        if session[:code]
          approver = Approver.where("code = ?", session[:code]).first
          @user = current_user
          if approver and (@user.email.downcase != approver.email.downcase)
            @user.set_second_email(approver.email.downcase)
            @user.save
          end
          session.delete(:code)
        end
    	if current_user.has_role? :admin
        @my_approvals = Approval.where("deadline >= ?",Date.today+1)        
      else
        @my_approvals = Approval.where("owner = ? and deadline >= ?", current_user.id, Date.today+1)       
      end  
    	@my_completed_approvals = Approval.where("owner = ? and deadline < ?", current_user.id, Date.today+1)
    	@pending_approvals = Approver.where("(email = ? or email = ? ) and (status = ? or status = ?)", current_user.email.downcase, current_user.second_email, "Pending", "")
    	@signedoff_approvals = Approver.where("(email = ? or email = ? ) and (status = ? or status = ?)", current_user.email.downcase, current_user.second_email, "Approved", "Declined")
    	@any_approvals = Approval.where("owner = ?", current_user.id)
    	@any_approvers = Approver.where("email = ? or email = ? ", current_user.email.downcase, current_user.second_email)
    end
  end
end
