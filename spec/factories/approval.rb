FactoryBot.define do
  factory :approval do
    title "Test"
    link "https://google.drive/file.pdf"
    deadline 3.days.from_now
    user
    approvers { create_list(:approver, 1, approval: self.instance_variable_get("@instance")) }
  end
end
