ActiveAdmin.register SubscriptionHistory do
  menu priority: 5

  actions :all, :except => [:new, :edit, :create]

  scope :all

  scope :lite
  scope :professional
  scope :unlimited

  scope :monthly
  scope :yearly

  index do
    id_column
    column(:user)
    column(:plan_name)
    column(:plan_interval)
    column(:created_at)
    actions
  end
end
