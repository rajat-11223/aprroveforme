FactoryBot.define do
  factory :subscription_history do
    plan_name { ["lite", "professional", "unlimited"].sample }
    plan_interval { ["monthly", "yearly"].sample }
    plan_date { 1.month.from_now }
    plan_identifier { Plans::List.new[plan_name].dig(plan_interval, "identifier") }
    renewable_date { 1.year.from_now }
    subscription_identifier { SecureRandom.alphanumeric(50) }
    user

    trait :lite do
      plan_name "lite"
    end

    trait :professional do
      plan_name "professional"
    end

    trait :unlimited do
      plan_name "unlimited"
    end
  end
end
