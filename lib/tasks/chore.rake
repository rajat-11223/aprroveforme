namespace :chore do
  desc "Clears the stripe customer_id and subscription_id for staging and development"
  task :clean_up_stripe_customers => :environment do
    if Rails.env.development? || Rails.env.staging?
      User.update_all(customer_id: nil, stripe_subscription_id: nil)
      puts "done."
    else
      puts "NOT RUNNING!!!"
    end
  end

  desc "Clear Sidekiq jobs"
  task :clear_sidekiq_jobs => :environment do
    Sidekiq::Queue.new.clear
  end

  desc "Compute completed_at"
  task :compute_completed_at => :environment do
    Approval.not_complete.find_each do |approval|
      case
      when approval.deadline < Time.zone.now
        approval.update_attributes completed_at: approval.deadline
      when approval.created_at < (Time.zone.now - 5.months)
        approval.update_attributes completed_at: Time.zone.now
      end

      print "."
    end
  end
end
