class AddAuthorToTasks < ActiveRecord::Migration[5.0]
  def change
    add_column :tasks, :author, :integer
  end
end
