class FreeToLite < ActiveRecord::Migration[5.2]
  def up
    SubscriptionHistory.lite.update_all plan_type: :lite
  end

  def down
    SubscriptionHistory.lite.update_all plan_type: :free
  end
end
