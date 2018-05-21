class CreateSubscriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :subscriptions do |t|
      t.string :plan_type
      t.date :plan_date
      t.date :renewable_date
      t.integer :user_id

      t.timestamps
    end
  end
end
