class SubscriptionHistory < ApplicationRecord
  belongs_to :user

  default_scope -> { order(created_at: :desc)}
  validates_presence_of :plan_name
  validates_presence_of :plan_interval
  validates_presence_of :plan_identifier
  validates_presence_of :plan_date
  validates_presence_of :subscription_identifier

  scope :lite, -> { where(plan_name: :free).or(SubscriptionHistory.where(plan_name: :free)).or(SubscriptionHistory.where(plan_name: "")) }
  scope :professional, -> { where(plan_name: :professional) }
  scope :unlimited, -> { where(plan_name: :unlimited) }
end
