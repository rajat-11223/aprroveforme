FactoryBot.define do
  factory :approver do
    email "test@domain.com"
    name "Ricky Test"
    required "required"
    status { "pending" }

    trait :approved do
      status { "approved" }
    end

    trait :with_code do
      before(:create) { |approver| approver.generate_code }
    end

    before(:create) { |approver| approver.approval = build(:approval) }
  end
end
