class AddOwnerToApproval < ActiveRecord::Migration
  def change
    add_column :approvals, :owner, :integer
  end
end
