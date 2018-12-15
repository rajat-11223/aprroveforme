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
