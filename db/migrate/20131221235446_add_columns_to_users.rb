class AddColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :approvals_sent, :integer
    add_column :users, :approvals_received, :integer
    add_column :users, :approvals_responded_to, :integer
  end
end
