module HomeHelper
	def percentage_complete(approval)
	    @approver_count = approval.approvers.where("required = ?", "Required").count
      	@approved_count = approval.approvers.where("(status = ?) and (required = ?)", "Approved", "Required").count
	    if @approver_count > 0
	      return "#{((@approved_count*100)/@approver_count)}%"
	    else
	      return 0
	    end
	end

	def ratio_complete(approval)
		@approver_count = approval.approvers.where("required = ?", "Required").count
      	@approved_count = approval.approvers.where("(status = ?) and (required = ?)", "Approved", "Required").count

	    return "#{@approved_count}/#{@approver_count}"
	end
end
