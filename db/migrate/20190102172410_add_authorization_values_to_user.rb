class AddAuthorizationValuesToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :expires_at, :datetime
    add_column :users, :expires, :boolean
  end
end
