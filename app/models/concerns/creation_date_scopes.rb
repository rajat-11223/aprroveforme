module CreationDateScopes
  extend ActiveSupport::Concern

  included do
    scope :from_this_month, -> { where("created_at > ?", Time.zone.today.beginning_of_month.beginning_of_day) }
    scope :last_30_days, -> { where("created_at > ?", 30.days.ago.beginning_of_day) }
  end
end
