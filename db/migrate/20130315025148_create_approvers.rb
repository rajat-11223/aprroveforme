class CreateApprovers < ActiveRecord::Migration
  def change
    create_table :approvers do |t|
      t.string :email
      t.string :name
      t.string :required
      t.string :status

      t.timestamps
    end
  end
end
