class AddActivatedAtToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :activated_at, :datetime

    User.update_all("activated_at = updated_at")
  end
end
