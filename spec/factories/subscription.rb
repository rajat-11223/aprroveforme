FactoryBot.define do
  factory :subscription do
    plan_type { ["free", "professional", "unlimited"].sample }
    plan_date { 1.month.from_now }
    renewable_date { 1.year.from_now }
    user

    trait :free do
      plan_type "free"
    end

    trait :professional do
      plan_type "professional"
    end

    trait :unlimited do
      plan_type "unlimited"
    end
  end
end
