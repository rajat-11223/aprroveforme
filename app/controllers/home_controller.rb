class HomeController < ApplicationController
  before_action :set_session_code

  def index
    if current_user.present?
      redirect_to dashboard_home_index_path
    end

    authorize! :read, :homepage
  end

  def dashboard
    authorize! :read, Approval.new(owner: current_user.id)

    @my_approvals =
      if can? :manage, :all
        Approval.where("deadline >= ?", Date.today + 1)
      else
        Approval.where("owner = ? and deadline >= ?", current_user.id, Date.today+1)
      end

    @my_completed_approvals = Approval.where("owner = ? and deadline < ?", current_user.id, Date.today+1)
    @pending_approvals = Approver.where("(email = ? or email = ? ) and (status = ? or status = ?)", current_user.email.downcase, current_user.second_email, "Pending", "")
    @signedoff_approvals = Approver.where("(email = ? or email = ? ) and (status = ? or status = ?)", current_user.email.downcase, current_user.second_email, "Approved", "Declined")
    # @any_approvals = Approval.where("owner = ?", current_user.id)
    # @any_approvers = Approver.where("email = ? or email = ? ", current_user.email.downcase, current_user.second_email)

    user_subscription_date = current_user.subscription.plan_date
    @user_approvals = Approval.where(owner: current_user.id, created_at: user_subscription_date..(user_subscription_date + 30.days))
  end

  def pending_approvals
    authorize! :read, Approval.new(owner: current_user.id)

    @pending_approvals = Approver.where("(email = ? or email = ? ) and (status = ? or status = ?)", current_user.email.downcase, current_user.second_email, "Pending", "")
  end

  def open_approvals
    authorize! :read, Approval.new(owner: current_user.id)

    @my_approvals =
      if can? :manage, :all
        Approval.where("deadline >= ?", Date.today + 1)
      else
        Approval.where("owner = ? and deadline >= ?", current_user.id, Date.today + 1)
      end
  end

  def past_documents
    authorize! :create, Approval.new(owner: current_user.id)
    @my_completed_approvals = Approval.where("owner = ? and deadline < ?", current_user.id, Date.today+1)
  end

  def past_approvals
    authorize! :create, Approval.new(owner: current_user.id)
    @signedoff_approvals = Approver.where("(email = ? or email = ? ) and (status = ? or status = ?)", current_user.email.downcase, current_user.second_email, "Approved", "Declined")
  end

  private

  def set_session_code
    return unless session[:code]

    approver = Approver.find_by(code: session.delete(:code))
    return unless approver.present? && current_user.email.downcase != approver.email.downcase

    # Update current user to another known email address
    # TODO: determine if we should track ALL emails, not just a second
    current_user.update_attributes second_email: approver.email.downcase
  end
end
