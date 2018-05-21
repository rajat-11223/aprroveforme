class AddOwnerToApproval < ActiveRecord::Migration[5.0]
  def change
    add_column :approvals, :owner, :integer
  end
end
