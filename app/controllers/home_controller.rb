class HomeController < ApplicationController
  layout "application", only: [:index]

  before_action :require_user!, except: [:index]
  before_action :send_to_dashboard, only: [:index]

  def index
    authorize! :read, :homepage
  end

  def dashboard
    authorize! :read, Approval.new(owner: current_user.id)

    open_requests
    open_responses
  end

  def open_requests
    authorize! :read, Approval.new(owner: current_user.id)

    @open_requests = current_user.approvals.deadline_is_in_future
  end

  def complete_requests
    authorize! :read, Approval.new(owner: current_user.id)

    @complete_requests = current_user.approvals.deadline_is_past
  end

  def open_responses
    authorize! :read, Approval.new(owner: current_user.id)

    @open_responses = Approver.includes(:approval)
                              .pending
                              .by_user(current_user)
                              .select { |approver| !approver.approval.complete? }
  end

  def complete_responses
    authorize! :read, Approval.new(owner: current_user.id)

    @complete_responses = Approver.includes(:approval)
                                  .approved_or_declined
                                  .by_user(current_user)
                                  .select { |approver| approver.approval.complete? }
  end

  private

  def send_to_dashboard
    return unless current_user.present?

    redirect_to(dashboard_home_index_path)
  end
end
