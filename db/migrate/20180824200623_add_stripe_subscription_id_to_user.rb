class AddStripeSubscriptionIdToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :stripe_subscription_id, :string
    remove_column :users, :braintree_subscription_id
  end
end
