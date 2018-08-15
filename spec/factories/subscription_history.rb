FactoryBot.define do
  factory :subscription_history do
    plan_type { ["free", "professional", "unlimited"].sample }
    plan_date { 1.month.from_now }
    renewable_date { 1.year.from_now }
    user
  end
end
