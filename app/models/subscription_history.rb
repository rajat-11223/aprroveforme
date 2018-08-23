class SubscriptionHistory < ApplicationRecord
  belongs_to :user

  default_scope -> { order(created_at: :desc)}
  validates_presence_of :plan_type
  validates_presence_of :plan_date

  scope :lite, -> { where(plan_type: :free).or(SubscriptionHistory.where(plan_type: :free)).or(SubscriptionHistory.where(plan_type: "")) }
  scope :professional, -> { where(plan_type: :professional) }
  scope :unlimited, -> { where(plan_type: :unlimited) }
end
