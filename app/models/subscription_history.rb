class SubscriptionHistory < ApplicationRecord
  belongs_to :user

  default_scope -> { order(created_at: :desc)}
  validates_presence_of :plan_type
  validates_presence_of :plan_date
end
