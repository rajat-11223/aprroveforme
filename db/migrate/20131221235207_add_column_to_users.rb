class AddColumnToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :email_domain, :string
  end
end
