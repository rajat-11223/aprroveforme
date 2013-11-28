class AddPermsToApprovals < ActiveRecord::Migration
  def change
    add_column :approvals, :perms, :string
  end
end
