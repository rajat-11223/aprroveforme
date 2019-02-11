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
    {
      date: start_of_month,
      date_human: start_of_month.to_s,
      new_users: new_user_count(start_of_month),
      new_users_projected: new_user_projected_count(start_of_month),
      new_activated_users: new_activated_users_count(start_of_month),
      new_activated_user_rate: new_activated_user_rate(start_of_month).to_s + "%",
      new_activated_users_projected: new_activated_users_projected(start_of_month),
      total_users: user_count(start_of_month),
      new_approvals: new_approvals_count(start_of_month),
      new_users_approvals: new_activated_user_approvals_count(start_of_month),
      total_approvals: count_of(:created_ever, Approval, start_of_month: start_of_month),
      percent_new_approvals_by_new_users: find_percentage(new_activated_user_approvals_count(start_of_month), new_activated_users_count(start_of_month)).to_s + "%",
      percent_new_approvals_by_all_users: find_percentage(new_approvals_count(start_of_month), user_count(start_of_month)).to_s + "%",
    }
  end

  def find_percentage(a, b)
    ((a.to_f / b.to_f) * 100).round(2)
  end

  def count_of_new_activated_users_approvals(start_of_month:)
    new_users = relation_of(:created_this_month, User.activated, start_of_month: start_of_month).pluck(:id)

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

  def new_user_count(start_of_month)
    @new_user_count ||= {}
    @new_user_count[start_of_month] ||= count_of(:created_this_month, User, start_of_month: start_of_month)
  end

  def new_user_projected_count(start_of_month)
    @new_user_project_count ||= {}
    @new_user_project_count[start_of_month] ||= begin
      if start_of_month.end_of_month > Date.today
        users_so_far = new_user_count(start_of_month)
        days_passed_so_far = (Date.today - start_of_month) + 1
        days_left_in_month = start_of_month.end_of_month - Date.today

        users_so_far + ((users_so_far.to_f / days_passed_so_far) * days_left_in_month).to_i
      else
        new_user_count(start_of_month)
      end
    end
  end

  def new_activated_users_count(start_of_month)
    @new_activated_users_count ||= {}
    @new_activated_users_count[start_of_month] ||= count_of(:created_this_month, User.activated, start_of_month: start_of_month)
  end

  def new_activated_users_projected(start_of_month)
    @new_activated_users_projected ||= {}
    @new_activated_users_projected[start_of_month] ||= (new_user_projected_count(start_of_month) * new_activated_user_rate(start_of_month) / 100.0).to_i
  end

  def user_count(start_of_month)
    @user_count ||= {}
    @user_count[start_of_month] ||= count_of(:created_ever, User, start_of_month: start_of_month)
  end

  def new_approvals_count(start_of_month)
    @new_approvals_count ||= {}
    @new_approvals_count[start_of_month] ||= count_of(:created_this_month, Approval, start_of_month: start_of_month)
  end

  def new_activated_user_approvals_count(start_of_month)
    @new_activated_user_approvals_count ||= {}
    @new_activated_user_approvals_count[start_of_month] ||= count_of_new_activated_users_approvals(start_of_month: start_of_month)
  end

  def new_activated_user_rate(start_of_month)
    @new_activated_user_rate ||= {}
    @new_activated_user_rate[start_of_month] ||= find_percentage(new_activated_users_count(start_of_month), new_user_count(start_of_month))
  end
end
