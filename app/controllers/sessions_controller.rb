class SessionsController < ApplicationController
  skip_authorization_check

  def new
    if params[:state]
      session[:state] =
        begin
          JSON.parse(params[:state] || "{}")
        rescue JSON::ParserError
          {}
        end
    end

    session[:plan_name] = params[:plan_name]
    session[:plan_interval] = params[:plan_interval]
    redirect_to "/auth/google_oauth2?prompt=select_account"
  end

  def create
    auth = request.env["omniauth.auth"]
    Rails.logger.debug("Creating session with auth:")
    Rails.logger.debug(auth)
    Rails.logger.debug(session[:state])

    if auth["provider"] != "google_oauth2"
      Rollbar.warning("Unsupported OAuth provider", omniauth_details: auth)
      redirect_to root_path, notice: "We don't support that provider"
      return
    end

    Rails.logger.debug("Find, create, and sync user")
    user = User.find_by(provider: auth["provider"], uid: auth["uid"].to_s)

    if user.present?
      Google::SyncUser.new(user).call(auth)
    else
      user = User::CreateFromOmniauth.new(auth).call
    end

    User::LogLogin.new(user).call

    session[:user_id] = user.id

    Rails.logger.debug("Create Stripe Customer")
    PaymentGateway::CreateCustomer.new(user).call unless user.payment_customer?

    Rails.logger.debug("Create Stripe Subscription")
    if user.subscription.blank?
      PaymentGateway::CreateSubscription.new(user).call(name: SubscriptionHistory::LITE, interval: SubscriptionHistory::MONTHLY)
      user.reload
    end

    session[:state] ||= {}
    ab_finished(:signed_in)

    if user.name.blank?
      redirect_to edit_user_path(user), alert: "Please enter your name."
      return
    end

    if ["create", "open"].include?(session[:state]["action"].to_s)
      redirect_to new_approval_url
      return
    end

    if user.subscription.plan_name == SubscriptionHistory::LITE
      redirect_to dashboard_home_index_path
    else
      redirect_to_redirection_path
    end
  end

  def destroy
    reset_session
    redirect_to root_url, notice: "You have successfully signed out."
  end

  def failure
    redirect_to root_url, alert: "Authentication error: #{params[:message]}."
  end
end
