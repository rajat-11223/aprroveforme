class AddStatsColumnsToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :approvals_sent_30, :integer
    add_column :users, :approvals_received_30, :integer
    add_column :users, :approvals_responded_to_30, :integer
  end
end
