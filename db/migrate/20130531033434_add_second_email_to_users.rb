class AddSecondEmailToUsers < ActiveRecord::Migration
  def change
    add_column :users, :second_email, :string
  end
end
