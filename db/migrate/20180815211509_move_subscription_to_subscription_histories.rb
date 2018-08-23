class MoveSubscriptionToSubscriptionHistories < ActiveRecord::Migration[5.2]
  def up
    Subscription.find_each do |subscription|
      puts "Moving Subscription Data"
      next unless subscription.user_id.present?

      plan_type =
       if ["lite", "professional", "unlimited"].include?(subscription.plan_type)
         subscription.plan_type
       else
         "lite"
       end

      sh = SubscriptionHistory.create user_id: subscription.user_id,
                                   plan_type: plan_type,
                                   plan_date: subscription.plan_date,
                                   created_at: subscription.created_at,
                                   updated_at: subscription.updated_at

      print '.'
    end

    puts
  end
end
