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
    def plan_approval
    	if !Subscription.find_by_user_id(current_user.id).nil?
        	@subscription =  Subscription.find_by_user_id(current_user.id).plan_type
        	if @subscription == "free"
        		return "free"
        	elsif @subscription == "professional"
        		return "professional"
        	else
        		return "unlimited"
        	end
        end    
    		
    end
    def approval_accord_plan
    	
    	if plan_approval == "free"
    		@approval = Approval.find_all_by_owner(current_user.id)
    		if @approval.count <=1
    		   return true
    		else
    		   return false
    		end
    	elsif plan_approval == "professional"
    		@approval = Approval.find_all_by_owner(current_user.id)
    		if @approval.count <= 5
    		   return true
    		else
    		   return false
    		end
    	else
    		return true
    	end		
    end


end
