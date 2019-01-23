class SystemStats
  def initialize(range = nil)
    @range = range || 12.times.map { |i| Time.zone.today.beginning_of_month - i.month }.reverse
  end

  def call
    @call ||= range.map { |start_of_month| basic_stats(start_of_month) }
  end

  private

  attr_reader :range

  def basic_stats(start_of_month)
    new_user_count = count_of(:created_this_month, User, start_of_month: start_of_month)
    new_activated_users_count = count_of(:created_this_month, User.activated, start_of_month: start_of_month)
    user_count = count_of(:created_ever, User, start_of_month: start_of_month)
    new_approvals_count = count_of(:created_this_month, Approval, start_of_month: start_of_month)
    new_user_approvals_count = count_of_new_users_approvals(start_of_month: start_of_month)

    {
      date: start_of_month,
      date_human: start_of_month.to_s,
      new_users: new_user_count,
      new_activated_users: new_activated_users_count,
      total_users: user_count,
      new_approvals: new_approvals_count,
      new_users_approvals: new_user_approvals_count,
      total_approvals: count_of(:created_ever, Approval, start_of_month: start_of_month),
      percent_new_approvals_by_new_users: find_percentage(new_user_approvals_count, new_user_count),
      percent_new_approvals_by_all_users: find_percentage(new_approvals_count, user_count),
    }
  end

  def find_percentage(a, b)
    ((a.to_f / b.to_f) * 100).round(2)
  end

  def count_of_new_users_approvals(start_of_month:)
    new_users = relation_of(:created_this_month, User, start_of_month: start_of_month).pluck(:id)

    count_of(:created_this_month, Approval.where(owner: new_users), start_of_month: start_of_month)
  end

  def count_of(type, association, start_of_month: nil)
    relation_of(type, association, start_of_month: start_of_month).count
  end

  def relation_of(type, association, start_of_month: nil)
    end_of_month = start_of_month.end_of_month

    case type
    when :created_this_month
      association.where("created_at > ? AND created_at < ?", start_of_month, end_of_month)
    when :created_ever
      association.where("created_at < ?", start_of_month.end_of_month)
    else
      raise "Unknown: #{type}"
    end
  end
end
