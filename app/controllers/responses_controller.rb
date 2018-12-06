class ResponsesController < ApplicationController
  skip_authorization_check

  before_action :set_approver_and_approval
  before_action :require_approver_and_approval, only: [:update]

  def show
  end

  # an approver is approving
  def update
    if !@approval.past_due? && @approver.update_attributes!(approver_params)
      ab_finished(:approver_approved)
      UserMailer.approval_update(@approver).deliver_later

      @approval.is_completable? && @approval.mark_as_complete! && UserMailer.completed_approval(@approval).deliver_later

      redirect_to response_path(@approver, code: @approver.code)
    else
      render :show
    end
  end

  private

  def set_approver_and_approval
    code = params.dig(:code) || params.dig(:approver, :code)

    @approver = Approver.find_by(id: params[:id], code: code)
    @approval = @approver.try(:approval)
    @request_type = @approval.try(:request_type)
  end

  def require_approver_and_approval
    return if @approver && @approval

    redirect_to response_path(@approver)
  end

  def approver_params
    params.require(:approver).permit(:status, :comments)
  end
end
