ActiveAdmin.register_page "Dashboard" do
  menu priority: 1, label: proc { I18n.t("active_admin.dashboard") }

  content title: proc { I18n.t("active_admin.dashboard") } do
    system_stats = SystemStats.new.call

    columns do
      column do
        panel "Quick Stats" do
          ul do
            li "#{system_stats.last[:total_users]} TOTAL USERS"
            li "#{system_stats.last[:total_approvals]} TOTAL APPROVALS SENT"
            li "#{Approval.where("created_at >= ?", Time.zone.today).count} DAILY NEW APPROVALS"
            li "#{Approval.where("created_at >= ?", 1.week.ago).count} WEEKLY NEW APPROVALS"
            li "#{system_stats.last[:new_approvals]} MONTHLY NEW APPROVALS"
            li "#{User.where("created_at >= ?", Time.zone.today).count} DAILY NEW USERS"
            li "#{User.where("created_at >= ?", 1.week.ago).count} WEEKLY NEW USERS"
            li "#{system_stats.last[:new_users]} MONTHLY NEW USERS"
          end
        end

        panel "Last Year of Stats" do
          table_for system_stats.reverse do
            column("Month (first day of month)") { |monthly_stats| monthly_stats[:date_human] }
            column("Total Users") { |monthly_stats| monthly_stats[:total_users] }
            column("New Users - Signed Up") { |monthly_stats| monthly_stats[:new_users] }
            column("New Users - Activated") { |monthly_stats| monthly_stats[:new_activated_users] }
            column("New Approvals") { |monthly_stats| monthly_stats[:new_approvals] }
            column("New Approvals (by new activated users)") { |monthly_stats| monthly_stats[:new_users_approvals] }
            column("Total Approvals") { |monthly_stats| monthly_stats[:total_approvals] }
            column("% New Approvals (by new activated users)") { |monthly_stats| monthly_stats[:percent_new_approvals_by_new_users] }
            column("% New Approvals (by all users)") { |monthly_stats| monthly_stats[:percent_new_approvals_by_all_users] }
          end
        end
      end
    end
  end
end
