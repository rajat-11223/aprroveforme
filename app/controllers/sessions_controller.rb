class SessionsController < ApplicationController
  skip_authorization_check

  def new
    if params[:state]
      session[:state] =
        begin
          JSON.parse(params[:state] || '{}')
        rescue JSON::ParserError
          {}
        end
    end

    session[:plan_type] = params[:plan_type]
    redirect_to '/auth/google_oauth2?prompt=select_account'
  end

  def create
    auth = request.env["omniauth.auth"]

    if auth['provider'] != 'google_oauth2'
      Rollbar.warning("Unsupported OAuth provider", omniauth_details: auth)
      redirect_to root_path, notice: "We don't support that provider"
      return
    end

    user = User.find_by(provider: auth['provider'], uid: auth['uid'].to_s) ||
            User.create_with_omniauth(auth)

    session[:user_id] = user.id

    if user.customer_id.blank?
      customer = Braintree::Customer.create(email: user.email, first_name: user.first_name, last_name: user.last_name)
      user.customer_id = customer.customer.id
    end

    if !user.subscription.present?
      user.subscription_histories.create!(plan_type: 'free', plan_date: Time.now)
      user.save
      user.reload
    end

    # TODO: update users first_name, last_name, photo, etc.

    # Credentials
    session[:credentials] = auth.dig("credentials")
    ab_finished(:signed_in)
    user.update_attributes! token: auth.dig("credentials", "token") || "",
                            refresh_token: auth.dig("credentials", "refresh_token") || user.refresh_token,
                            code: params["code"] || ""

    session[:state] ||= {}

    if !user.name.present?
      redirect_to edit_user_path(user), alert: "Please enter your name."
    else
      if ['create', 'open'].include? session[:state]['action'].to_s
        redirect_to new_approval_url
      else
        if user.subscription.plan_type == "free"
          redirect_to pricing_url
        else
          redirect_to_redirection_path
        end
      end
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
