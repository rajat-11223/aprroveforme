FactoryBot.define do
  factory :user do
    name { "Kim Manis" }
    email { "kimmanis@gmail.com" }
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
      create(:subscription_history, user: user)
      user.reload
    end
  end

  # factory :admin, class: User do
  #   email "kimmanis@gmail.com"
  #   picture "https://lh4.googleusercontent.com/-AU_9Qx9sUXw/AAAAAAAAAAI/AAAAAAAAAAA/hXcwDv3KdZI/photo.jpg"
  # end
end
