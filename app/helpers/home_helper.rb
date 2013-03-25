module HomeHelper
	def percentage_complete(approval)
	    @approver_count = approval.approvers.count
	    @approved_count = approval.approvers.where("status = ?", "Approved").count
	    if @approver_count > 0
	      return "#{((@approved_count*100)/@approver_count)}%"
	    else
	      return 0
	    end
	end
end
