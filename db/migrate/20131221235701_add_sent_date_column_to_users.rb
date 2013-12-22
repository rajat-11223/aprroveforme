class AddSentDateColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :last_sent_date, :datetime
  end
end
