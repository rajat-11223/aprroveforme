class CreateSubscriptionHistories < ActiveRecord::Migration[5.0]
  def change
    create_table :subscription_histories do |t|
      t.string :plan_type
      t.datetime :plan_date
      t.datetime :renewable_date
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
