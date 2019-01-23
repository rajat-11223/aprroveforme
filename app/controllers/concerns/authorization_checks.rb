module AuthorizationChecks
  extend ActiveSupport::Concern

  included do
    check_authorization unless: :excluded_authed_controller?

    rescue_from CanCan::AccessDenied do |exception|
      redirect_to root_path, :alert => exception.message
    end
  end

  def access_denied(exception)
    redirect_to root_path, alert: exception.message
  end

  private

  def excluded_authed_controller?
    active_admin_controller?
  end

  def active_admin_controller?
    self.is_a? ActiveAdmin::BaseController
  end

  def authenticate_admin_user!
    redirect_to sign_in_path unless can?(:manage, :all)
  end

  def require_user!(message: "You need to sign in")
    return if current_user && current_user.activated?
    (redirect_to(need_to_activate_account_path) && return) if current_user && !current_user.activated?

    save_redirection_url!
    redirect_to root_path, notice: message
  end
end
