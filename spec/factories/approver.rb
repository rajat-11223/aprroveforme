FactoryBot.define do
  factory :approver do
    email "test@domain.com"
    name "Ricky Test"
    required "required"
    status "pending"


    before(:create) { |approver| approver.approval = build(:approval) }
  end
end
