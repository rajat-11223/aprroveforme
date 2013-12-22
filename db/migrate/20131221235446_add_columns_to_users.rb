class AddColumnsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :approvals_sent, :integer
    add_column :users, :approvals_received, :integer
    add_column :users, :approvals_responded_to, :integer
  end
end
