class AddBraintreeSubscriptionIdToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :braintree_subscription_id, :string
  end
end
