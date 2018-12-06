class ApproverController < ApplicationController
  def show
    @approver = Approver.find(params[:id])
    authorize! :read, @approver
  end

  def edit
    @approver = Approver.find(params[:id])
    authorize! :edit, @approver
  end

  def update
    @approver = Approver.find(params[:id])
    authorize! :update, @approver

    if @approver.update_attributes(approver_params)
      redirect_to @approver.approval, notice: "Approval was successfully updated."
    else
      render action: "edit"
    end
  end

  def approver_params
    params.require(:approver).permit(:id, :email, :name, :required)
  end
end
