class AddNullAndDefaultsToApprovalFields < ActiveRecord::Migration[5.2]
  def change
    change_column_null :approvals, :deadline, false
    change_column_default :approvals, :description, ""
    change_column_null :approvals, :description, false
    change_column_null :approvals, :owner, false
    change_column_null :approvals, :title, false
  end
end
