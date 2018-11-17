namespace :chore do
  desc "Clears the stripe customer_id and subscription_id for staging and development"
  task :clean_up_stripe_customers => :environment do
    if Rails.env.development?
      User.update_all(customer_id: nil, stripe_subscription_id: nil)
      puts "done."
    else
      puts "NOT RUNNING!!!"
    end
  end
end
