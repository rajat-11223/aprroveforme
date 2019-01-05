# == Schema Information
#
# Table name: subscription_histories
#
#  id                      :integer          not null, primary key
#  plan_date               :datetime
#  plan_identifier         :string           not null
#  plan_interval           :string           not null
#  plan_name               :string           not null
#  renewable_date          :datetime
#  subscription_identifier :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :integer
#
# Indexes
#
#  index_subscription_histories_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

class SubscriptionHistory < ApplicationRecord
  belongs_to :user

  default_scope -> { order(created_at: :desc) }
  validates_presence_of :plan_name
  validates_presence_of :plan_interval
  validates_presence_of :plan_identifier
  validates_presence_of :plan_date
  validates_presence_of :subscription_identifier

  LITE = "lite"
  PROFESSIONAL = "professional"
  UNLIMITED = "unlimited"

  MONTHLY = "monthly"
  YEARLY = "yearly"

  scope :lite, -> { where(plan_name: LITE) }
  scope :professional, -> { where(plan_name: PROFESSIONAL) }
  scope :unlimited, -> { where(plan_name: UNLIMITED) }

  scope :monthly, -> { where(plan_interval: MONTHLY) }
  scope :yearly, -> { where(plan_interval: YEARLY) }

  def stripe_subscription
    @stripe_subscription ||= Stripe::Subscription.retrieve(subscription_identifier)
  rescue Stripe::InvalidRequestError
    nil
  end

  def lite?
    plan_name == LITE
  end

  def professional?
    plan_name == PROFESSIONAL
  end

  def unlimited?
    plan_name == UNLIMITED
  end

  def monthly?
    plan_interval == MONTHLY
  end

  def yearl?
    plan_interval == YEARLY
  end
end
