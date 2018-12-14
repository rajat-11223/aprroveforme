module SetCurrentUser
  extend ActiveSupport::Concern

  included do
    before_action :set_current_time_zone
    before_action :set_current_user
  end

  private

  def set_current_time_zone
    Current.time_zone = browser_timezone
  end

  def set_current_user
    Current.user = current_user
  end
end
