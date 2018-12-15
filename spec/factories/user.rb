FactoryBot.define do
  factory :user do
    uid { rand(10_000) }

    sequence :name do |n|
      "Kim Manis-#{n}"
    end
    first_name { name.split(" ")[0] }
    last_name { name.split(" ")[1] }
    provider { "google_oauth2" }

    sequence :email do |n|
      "kimmanis-#{n}@gmail.com"
    end
    picture "https://lh4.googleusercontent.com/-AU_9Qx9sUXw/AAAAAAAAAAI/AAAAAAAAAAA/hXcwDv3KdZI/photo.jpg"
  end

  trait :admin do
    name { "Mrs. Admin" }
    email { "admin@takeovertheworld.com" }
    after(:create) do |user|
      user.add_role :admin
    end
  end

  trait :with_subscription do
    after(:create) do |user|
      create(:subscription_history, :lite, user: user)
      user.reload
    end
  end

  # factory :admin, class: User do
  #   email "kimmanis@gmail.com"
  #   picture "https://lh4.googleusercontent.com/-AU_9Qx9sUXw/AAAAAAAAAAI/AAAAAAAAAAA/hXcwDv3KdZI/photo.jpg"
  # end
end
