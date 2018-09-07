class AddLastLoginAtToUser < ActiveRecord::Migration[5.2]
  def up
    add_column :users, :last_login_at, :datetime
    User.update_all('last_login_at = updated_at')
  end

  def down
    remove_column :users, :last_login_at
  end
end
