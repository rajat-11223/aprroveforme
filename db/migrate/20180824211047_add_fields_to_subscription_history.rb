class AddFieldsToSubscriptionHistory < ActiveRecord::Migration[5.2]
  def up
    SubscriptionHistory.destroy_all

    remove_column :subscription_histories, :plan_type, :string, null: false

    add_column :subscription_histories, :plan_name, :string, null: false
    add_column :subscription_histories, :plan_interval, :string, null: false
    add_column :subscription_histories, :plan_identifier, :string, null: false
    add_column :subscription_histories, :subscription_identifier, :string, null: false
  end
end
