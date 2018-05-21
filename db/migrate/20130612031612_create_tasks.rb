class CreateTasks < ActiveRecord::Migration[5.0]
  def change
    create_table :tasks do |t|
      t.text :comment
      t.integer :status
      t.references :approver

      t.timestamps
    end
    # add_index :tasks, :approver_id
  end
end
