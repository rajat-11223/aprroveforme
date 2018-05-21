class ChangeStatusForTasks < ActiveRecord::Migration[5.0]
  def self.up
   change_column :tasks, :status, :string
  end

  def self.down
   change_column :tasks, :status, :integer
  end
end
