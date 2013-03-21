module ApprovalsHelper

	def get_status(status)
		if status == "Pending"
			return "warning"
		elsif status == "Approved"
			return "success"
		elsif status == "Declined"
			return "error"
		else
			return "info"
		end
	end


	# this is new!!!!
	  def approver_answer(id, email, response, comments)
	    @approval = Approval.find(id)
	    @approver = @approval.approvers.where("email = ?", email).first
	    @approver.status = response
	    @approver.comments = comments
	    @approver.save

	      if @approver.update_attributes(params[:approval])
	        format.html { redirect_to @approver.approval, notice: 'Approval was successfully updated.' }
	        format.json { head :no_content }
	      else
	        format.html { render action: "edit" }
	        format.json { render json: @approver.approval.errors, status: :unprocessable_entity }
	      end
	    
	  end

end
