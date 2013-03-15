class CreateApprovals < ActiveRecord::Migration
  def change
    create_table :approvals do |t|
      t.string :title
      t.string :link
      t.text :description
      t.datetime :deadline

      t.timestamps
    end
  end
end
