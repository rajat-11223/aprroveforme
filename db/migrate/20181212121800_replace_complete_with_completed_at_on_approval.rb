class ReplaceCompleteWithCompletedAtOnApproval < ActiveRecord::Migration[5.2]
  def change
    add_column :approvals, :completed_at, :datetime
    remove_column :approvals, :complete, :boolean, default: false

    add_index :approvals, :completed_at
  end
end
