class AddApprovalToTasks < ActiveRecord::Migration[5.0]
  def change
    add_column :tasks, :approval_id, :integer
  end
end
