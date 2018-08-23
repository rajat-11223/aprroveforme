FactoryBot.define do
  factory :subscription_history do
    plan_type { ["lite", "professional", "unlimited"].sample }
    plan_date { 1.month.from_now }
    renewable_date { 1.year.from_now }
    user

    trait :lite do
      plan_type "lite"
    end

    trait :professional do
      plan_type "professional"
    end

    trait :unlimited do
      plan_type "unlimited"
    end
  end
end
