class AddApprovalToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :approval_id, :integer
  end
end
