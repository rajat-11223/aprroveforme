class AddApprovalIdToApprover < ActiveRecord::Migration[5.0]
  def change
    add_column :approvers, :approval_id, :integer
  end
end
