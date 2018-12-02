class HomeController < ApplicationController
  layout "application", only: [:index]

  before_action :set_second_email
  before_action :require_user!, except: [:index]

  def index
    redirect_to(dashboard_home_index_path) if current_user.present?

    authorize! :read, :homepage
  end

  def dashboard
    authorize! :read, Approval.new(owner: current_user.id)

    base_approvals = current_user.approvals

    @my_approvals = base_approvals.deadline_is_in_future
    @my_completed_approvals = base_approvals.deadline_is_past

    base_approver = Approver.by_user(current_user)
    @pending_approvals = base_approver.pending
    @signedoff_approvals = base_approver.approved_or_declined

    user_subscription_date = current_user.subscription.plan_date
    @user_approvals = current_user.approvals.from_this_month
  end

  def pending_approvals
    authorize! :read, Approval.new(owner: current_user.id)

    @pending_approvals = Approver.includes(:approval)
                                 .pending
                                 .by_user(current_user)
                                 .select { |approver| !approver.approval.complete? }
  end

  def open_approvals
    authorize! :read, Approval.new(owner: current_user.id)

    @my_approvals = current_user.approvals.deadline_is_in_future
  end

  def past_documents
    authorize! :read, Approval.new(owner: current_user.id)

    @my_completed_approvals = current_user.approvals.deadline_is_past
  end

  def past_approvals
    authorize! :read, Approval.new(owner: current_user.id)

    @signedoff_approvals = Approver.includes(:approval)
      .approved_or_declined
      .by_user(current_user)
      .select { |approver| approver.approval.complete? }
  end

  private

  def set_second_email
    return unless session[:code]

    approver = Approver.find_by(code: session.delete(:code))
    return unless approver.present? && current_user.present? && current_user.email.downcase != approver.email.downcase

    # Update current user to another known email address
    # TODO: determine if we should track ALL emails, not just a second
    current_user.update_attributes second_email: approver.email.downcase
  end
end
