class Current < ActiveSupport::CurrentAttributes
  attribute :user, :time_zone

  def user=(user)
    tz = if user.try(:time_zone?)
           user.time_zone
         else
           persist_tz(user, Current.time_zone)
           Current.time_zone
         end

    Time.zone = tz
    super
  end

  def time_zone=(tz)
    Time.zone = tz.presence
    super
  end

  private

  def persist_tz(user, tz)
    return unless user.present? && tz.present?
    return unless user.time_zone.nil?

    Rails.logger.info("Persisting tz #{user} with #{tz}")
    user.update_attributes time_zone: tz
  end
end
