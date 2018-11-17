class ApplicationController < ActionController::Base
  protect_from_forgery

  include RedirectUnlessOnProperDomain
  include TurbolinksCacheControl

  helper_method :current_user
  helper_method :user_signed_in?
  helper_method :correct_user?

  before_action :set_code
  before_action :setup_gon

  check_authorization

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_path, :alert => exception.message
  end

  private
    def current_user
      return  unless session[:user_id]

      begin
        @current_user ||= User.includes(:subscription).find(session[:user_id])
      rescue ActiveRecord::RecordNotFound
        nil
      end
    end

    def user_signed_in?
      current_user.present?
    end

    def require_user!(message: "You need to sign in")
      return if current_user
      save_redirection_url!

      redirect_to root_path, notice: message
    end

    def require_subscription
      redirect_to pricing_path, notice: "Please subscribe to a plan to continue creating approvals" unless current_user.subscription.present?
    end

    def require_remaining_approvals_in_plan
      return unless current_user
      details = PlanDetails.new(current_user)
      return if details.has_remaining_approvals?

      redirect_to pricing_path,
        notice: "Please upgrade your plan to continue creating approvals. You have used #{details.current_approval_count} of #{details.approval_limit_in_words.downcase} this month"
    end

    def save_redirection_url!
      session[:redirection_url] = request.url
    end

    def redirect_to_redirection_path
      redirection_url = session.delete(:redirection_url)
      redirect_to(redirection_url || root_url)
    end

    def set_code
      return unless params["code"].present?

      session[:code] = params["code"]
    end

    def setup_gon
      gon.push googleAppId: ENV.fetch("APP_ID"),
               googleUserToken: current_user.try(:token),
               stripePublishableKey: ENV.fetch("STRIPE_PUBLISHABLE_KEY"),
               pageName: [controller_name.camelize, action_name.camelize].join
    end
end
