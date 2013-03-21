class ApproverController < ApplicationController

  def show
    @approver = Approver.find(params[:id])
  end

  def edit
    @approver = Approver.find(params[:id])
  end

  def update
    @approver = Approver.find(params[:id])

    respond_to do |format|
      if @approver.update_attributes(params[:approver])
        format.html { redirect_to @approver.approval, notice: 'Approval was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @approver.approval, status: :unprocessable_entity }
      end
    end
  end

end
