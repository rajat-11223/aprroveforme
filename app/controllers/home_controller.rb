class HomeController < ApplicationController
  before_action :check_current_user, except: :index
  before_action :session_code, except: :index

  def index
    if current_user
      session_code

      @my_approvals =
        if current_user.has_role? :admin
          Approval.deadline_after_one_day_from_now
        else
          Approval.deadline_after_one_day_from_now.where(owner: current_user.id)
        end

      @my_completed_approvals = Approval.where("owner = ? AND deadline < ?", current_user.id, Date.today+1)
      @pending_approvals = Approver.where("(email = ? OR email = ?) AND (status = ? OR status = ?)", current_user.email.downcase, current_user.second_email, "Pending", "")
      @signedoff_approvals = Approver.where("(email = ? OR email = ?) AND (status = ? OR status = ?)", current_user.email.downcase, current_user.second_email, "Approved", "Declined")
      @any_approvals = Approval.where("owner = ?", current_user.id)
      @any_approvers = Approver.where("email = ? OR email = ?", current_user.email.downcase, current_user.second_email)

      user_subscription_date = current_user.subscription.plan_date
      @user_approvals = Approval.where(owner: current_user.id).where(created_at: user_subscription_date..(user_subscription_date + 30.days))
    end
  end

  def pending_approvals
    @pending_approvals = Approver.where("(email = ? OR email = ? ) AND (status = ? OR status = ?)", current_user.email.downcase, current_user.second_email, "Pending", "")
  end

  def open_approvals
    @my_approvals
      if current_user.has_role? :admin
        Approval.deadline_after_one_day_from_now
      else
        Approval.deadline_after_one_day_from_now.where(owner: current_user.id)
      end
  end

  def past_documents
    @my_completed_approvals = Approval.where("owner = ? AND deadline < ?", current_user.id, Date.today+1)
  end

  def past_approvals
    @signedoff_approvals = Approver.where("(email = ? OR email = ?) AND (status = ? OR status = ?)", current_user.email.downcase, current_user.second_email, "Approved", "Declined")
  end

  private

  def check_current_user
    if current_user == nil
      redirect_to root_path , notice: 'You need to LOGIN or SIGNUP to perform this action'
    end
  end

  def session_code
    if session[:code]
      approver = Approver.where("code = ?", session[:code]).first
      @user = current_user
      if approver and (@user.email.downcase != approver.email.downcase)
        @user.set_second_email(approver.email.downcase)
        @user.save
      end
      session.delete(:code)
    end
  end

  # def plan_responses_limit
  #   case current_user.subscription.plan_type
  #   when 'free'
  #     2
  #   when 'professional'
  #     6
  #   end
  # end

end
