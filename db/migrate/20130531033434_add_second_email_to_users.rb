class AddSecondEmailToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :second_email, :string
  end
end
