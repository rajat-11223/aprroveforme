class PlanDetails
  def initialize(user)
    @user = user
  end

  def name
    user.subscription.plan_name.presence || "lite"
  end

  def approval_limit
    plan["reviews_each_month"]
  end

  def approval_limit_in_words
    plan["reviews_each_month_in_words"].to_s
  end

  def has_remaining_approvals?
    approval_limit > current_approval_count
  end

  def current_approval_count
    @current_approval_count ||= user.approvals.from_this_month.count
  end

  private

  attr_reader :user

  def plan
    @plan ||= Plans::List[name]
  end
end
