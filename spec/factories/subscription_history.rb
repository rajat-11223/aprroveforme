FactoryBot.define do
  factory :subscription_history do
    plan_name { [SubscriptionHistory::LITE, SubscriptionHistory::PROFESSIONAL, SubscriptionHistory::UNLIMITED].sample }
    plan_interval { [SubscriptionHistory::MONTHLY, SubscriptionHistory::YEARLY].sample }
    plan_date { 1.month.from_now }
    plan_identifier { Plans::List.new[plan_name].dig(plan_interval, "identifier") }
    renewable_date { 1.year.from_now }
    subscription_identifier { SecureRandom.alphanumeric(50) }
    user

    trait :lite do
      plan_name SubscriptionHistory::LITE
    end

    trait :professional do
      plan_name SubscriptionHistory::PROFESSIONAL
    end

    trait :unlimited do
      plan_name SubscriptionHistory::UNLIMITED
    end
  end
end
