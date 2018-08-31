namespace :chore do
  desc "This task clears the stripe customer_id and subscription_id for staging and development"
  task :clean_up_stripe_customers => :environment do
    return if Rails.env.production?

    User.update_all(customer_id: nil, stripe_subscription_id: nil)
    puts "done."
  end
end
