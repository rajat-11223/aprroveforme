class SubscriptionHistory < ApplicationRecord
  belongs_to :user

  validates_presence_of :plan_type
  validates_presence_of :plan_date
end
