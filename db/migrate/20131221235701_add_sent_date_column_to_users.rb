class AddSentDateColumnToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :last_sent_date, :datetime
  end
end
