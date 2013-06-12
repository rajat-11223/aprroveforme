class AddAuthorToTasks < ActiveRecord::Migration
  def change
    add_column :tasks, :author, :integer
  end
end
