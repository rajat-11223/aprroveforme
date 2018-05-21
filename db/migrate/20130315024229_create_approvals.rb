class CreateApprovals < ActiveRecord::Migration[5.0]
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
