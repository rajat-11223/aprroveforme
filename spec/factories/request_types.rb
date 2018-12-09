FactoryBot.define do
  factory :request_type do
    name "Slug Slug"
    affirming_text "Good"
    dissenting_text "Not Good"
    allow_dissenting true
    slug "slugger"
    public true

    initial_subject { Faker::Lorem.sentence }
    initial_body { Faker::Lorem.paragraph }
    reminder_subject { Faker::Lorem.sentence }
    reminder_body { Faker::Lorem.paragraph }
    due_soon_subject { Faker::Lorem.sentence }
    due_soon_body { Faker::Lorem.paragraph }
    due_now_subject { Faker::Lorem.sentence }
    due_now_body { Faker::Lorem.paragraph }
    confirmation_responder_subject { Faker::Lorem.sentence }
    confirmation_responder_body { Faker::Lorem.paragraph }
    completed_request_subject { Faker::Lorem.sentence }
    completed_request_body { Faker::Lorem.paragraph }
  end
end
