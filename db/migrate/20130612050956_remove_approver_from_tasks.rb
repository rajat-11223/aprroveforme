class RemoveApproverFromTasks < ActiveRecord::Migration
  def up
    remove_column :tasks, :approver_id
  end

  def down
    add_column :tasks, :approver_id, :integer
  end
end
