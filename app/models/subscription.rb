class Subscription < ActiveRecord::Base
  attr_accessible :plan_date, :plan_type, :renewable_date, :user_id
end
