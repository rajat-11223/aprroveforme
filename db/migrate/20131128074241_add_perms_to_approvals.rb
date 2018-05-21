class AddPermsToApprovals < ActiveRecord::Migration[5.0]
  def change
    add_column :approvals, :perms, :string
  end
end
