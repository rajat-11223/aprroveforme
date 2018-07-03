class HomeController < ApplicationController
  before_filter :check_current_user, except: :index

  def plan_responses_limit
    if current_user.subscription.plan_type == 'free'
      2
    else current_user.subscription.plan_type == 'professional'
    6
    end
  end

  def index
    if current_user
      session_code

      if current_user.has_role? :admin
        @my_approvals = Approval.where("deadline >= ?",Date.today+1)
      else
        @my_approvals = Approval.where("owner = ? and deadline >= ?", current_user.id, Date.today+1)
      end
      @my_completed_approvals = Approval.where("owner = ? and deadline < ?", current_user.id, Date.today+1)
      @pending_approvals = Approver.where("(email = ? or email = ? ) and (status = ? or status = ?)", current_user.email.downcase, current_user.second_email, "Pending", "")
      @signedoff_approvals = Approver.where("(email = ? or email = ? ) and (status = ? or status = ?)", current_user.email.downcase, current_user.second_email, "Approved", "Declined")
      @any_approvals = Approval.where("owner = ?", current_user.id)
      @any_approvers = Approver.where("email = ? or email = ? ", current_user.email.downcase, current_user.second_email)

      user_subscription_date = current_user.subscription.plan_date
      @user_approvals = Approval.where(:owner => current_user.id, :created_at => user_subscription_date..(user_subscription_date + 30.days))
    end
  end

  def pending_approvals
    session_code
    @pending_approvals = Approver.where("(email = ? or email = ? ) and (status = ? or status = ?)", current_user.email.downcase, current_user.second_email, "Pending", "")
  end

  def open_approvals
    session_code

    if current_user.has_role? :admin
      @my_approvals = Approval.where("deadline >= ?",Date.today+1)
    else
      @my_approvals = Approval.where("owner = ? and deadline >= ?", current_user.id, Date.today+1)
    end
  end

  def past_documents
    session_code
    @my_completed_approvals = Approval.where("owner = ? and deadline < ?", current_user.id, Date.today+1)
  end

  def past_approvals
    session_code
    @signedoff_approvals = Approver.where("(email = ? or email = ? ) and (status = ? or status = ?)", current_user.email.downcase, current_user.second_email, "Approved", "Declined")
  end

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

end
