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

    @open_requests = current_user.approvals
                                 .not_complete
  end

  def complete_requests
    authorize! :read, Approval.new(owner: current_user.id)

    @complete_requests = current_user.approvals
                                     .complete
  end

  def open_responses
    authorize! :read, Approval.new(owner: current_user.id)

    @open_responses = Approver.joins(:approval)
                              .merge(Approval.not_complete)
                              .not_responded
                              .by_user(current_user)
  end

  def complete_responses
    authorize! :read, Approval.new(owner: current_user.id)

    @complete_responses = Approver.includes(:approval)
                                  .responded
                                  .by_user(current_user)
  end

  private

  def send_to_dashboard
    return unless current_user.present?

    redirect_to(dashboard_home_index_path)
  end
end
