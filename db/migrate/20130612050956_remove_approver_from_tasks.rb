class RemoveApproverFromTasks < ActiveRecord::Migration[5.0]
  def up
    remove_column :tasks, :approver_id
  end

  def down
    add_column :tasks, :approver_id, :integer
  end
end
