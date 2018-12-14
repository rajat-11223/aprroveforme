class Current < ActiveSupport::CurrentAttributes
  attribute :user

  def user=(user)
    Time.zone = user.try(:time_zone) || "UTC"
    super
  end
end
