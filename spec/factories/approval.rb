FactoryBot.define do
  factory :approval do
    title "Test"
    link "https://google.drive/file.pdf"
    deadline 3.days.from_now
    user
    description { "" }
    approvers { [build(:approver)] }
  end
end
