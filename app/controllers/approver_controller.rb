class ApproverController < ApplicationController
  before_action :authenticate_user!
  def show
    @approver = Approver.find(params[:id])
  end

  def edit
    @approver = Approver.find(params[:id])
  end

  def update
    @approver = Approver.find(params[:id])

    respond_to do |format|
      if @approver.update_attributes(approver_params)
        format.html { redirect_to @approver.approval, notice: 'Approval was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @approver.approval, status: :unprocessable_entity }
      end
    end
  end
  
  def approver_params
    params.require(:approver).permit(:id, :email, :name, :required, :status, :comments, :code)
  end

end
