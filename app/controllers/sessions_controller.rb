class SessionsController < ApplicationController
  skip_authorization_check

  include ApplicationHelper

  def new
    if params[:state]
      s = params[:state] || '{}'
      state = MultiJson.decode(s)
      session[:state] = state
    end

    session[:plan_type] = params[:plan_type]
    redirect_to '/auth/google_oauth2'
  end

  def create
    auth = request.env["omniauth.auth"]
    user = User.find_by(provider: auth['provider'], uid: auth['uid'].to_s) ||
            User.create_with_omniauth(auth)
    session[:user_id] = user.id

    if user.customer_id.blank?
      customer = Braintree::Customer.create(email: user.email, first_name: user.first_name, last_name: user.last_name)
      user.customer_id = customer.customer.id
    end

    if !Subscription.exists?(user_id: current_user.id)
      Subscription.create!(plan_type: 'free', plan_date: Date.today, user: user)
      SubscriptionHistory.create!(plan_type: 'free', plan_date: Date.today, user: user)
    end

    # Credentials
    session[:credentials] = auth.dig("credentials")
    ab_finished(:signed_in)
    user.token = auth.dig("credentials", "token") || ""
    user.refresh_token = auth.dig("credentials", "refresh_token") if auth.dig("credentials", "refresh_token")
    user.code = params["code"] || ""

    if !user.name.present?
      redirect_to edit_user_path(user), alert: "Please enter your name."
    else
      user.save!

      redirect_to new_approval_path
      # if session[:state].present? and ['create', 'open'].include?(session[:state]['action'].to_s)
      #   redirect_to new_approval_path
      # else
      #   case session[:plan_type]
      #   when nil
      #     subscription = Subscription.find_by(user_id: current_user.id)
      #     if subscription.present?
      #       redirect_to_redirection_path
      #     else
      #       pricing_path
      #     end
      #   when "free"
      #     subscription = Subscription.find_by(user_id: current_user.id)
      #
      #     if !subscription.present?
      #       Subscription.create!(plan_type: "free", plan_date: Date.today, user: current_user)
      #       session[:plan_type] = nil
      #       redirect_to root_url
      #     else
      #       subscription.update_attributes plan_type: session[:plan_type], plan_date: Date.today
      #
      #       # subscription history
      #       SubscriptionHistory.create!(plan_type: session[:plan_type], plan_date: Time.now, user: current_user)
      #
      #       session[:plan_type] = nil
      #       session[:upgrade] = nil
      #       redirect_to root_url, notice: 'Congratulations, you have successfully downgraded your plan.'
      #     end
      #   else
      #     pricing_path
      #   end
      # end
    end
  end

  # def drive
  #   # Preload API definitions
  #   client = GoogleApiWrapper.new
  #
  #   # handle possible callback from OAuth2 consent page.
  #   if params[:code]
  #     authorize_code(params[:code])
  #   elsif params[:error] # User denied the oauth grant
  #     halt 403
  #   end
  # end
  #
  #
  # ##
  # # Exchanges the authorization code to fetch an access
  # # and refresh token. Stores the retrieved tokens in the session.
  # def authorize_code(code)
  #   api_client = GoogleApiWrapper.new
  #
  #   api_client.authorization.client_id = ENV['GOOGLE_ID']
  #   api_client.authorization.client_secret = ENV['GOOGLE_SECRET']
  #   api_client.authorization.scope = ENV['GOOGLE_SCOPE']
  #   api_client.authorization.redirect_uri = ENV['REDIRECT_URI']
  #   api_client.authorization.code = code
  #   api_client.authorization.fetch_access_token!
  #   api-client.authorization.additional_parameters = {
  #     "access_type" => "offline",         # offline access
  #     "include_granted_scopes" => "true"  # incremental auth
  #   }
  #
  #   api_client
  # end

  def destroy
    reset_session
    redirect_to root_url, notice: 'You have successfully signed out.'
  end

  def failure
    redirect_to root_url, alert: "Authentication error: #{params[:message]}."
  end
end
