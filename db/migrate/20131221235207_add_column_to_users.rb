class AddColumnToUsers < ActiveRecord::Migration
  def change
    add_column :users, :email_domain, :string
  end
end
