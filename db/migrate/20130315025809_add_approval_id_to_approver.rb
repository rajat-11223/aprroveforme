class AddApprovalIdToApprover < ActiveRecord::Migration
  def change
    add_column :approvers, :approval_id, :integer
  end
end
