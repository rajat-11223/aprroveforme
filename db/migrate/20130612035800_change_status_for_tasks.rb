class ChangeStatusForTasks < ActiveRecord::Migration
  def self.up
   change_column :tasks, :status, :string
  end

  def self.down
   change_column :tasks, :status, :integer
  end
end
