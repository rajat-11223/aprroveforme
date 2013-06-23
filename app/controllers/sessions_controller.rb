class SessionsController < ApplicationController

  def new
    if params[:state]
      s = params[:state] || '{}'
      state = MultiJson.decode(s)
      session[:state] = state
    end
    redirect_to '/auth/google_oauth2'
  end


  def create
      auth = request.env["omniauth.auth"]
      user = User.where(:provider => auth['provider'], 
                        :uid => auth['uid'].to_s).first || User.create_with_omniauth(auth)
      session[:user_id] = user.id
      session[:credentials] = auth["credentials"]
      finished(:signed_in)
      user.token = auth["credentials"]["token"] || ""
      user.refresh_token = auth["credentials"]["refresh_token"] if auth["credentials"]["refresh_token"]
      user.code = params["code"] || ""
      user.add_role :admin if User.count == 1 # make the first user an admin
      if user.email.blank?
        redirect_to edit_user_path(user), :alert => "Please enter your email address."
      else
        user.save
        if session[:state] and (session[:state]['action'] == 'create' || 'open')
          redirect_to new_approval_path
        else
          redirect_to root_url
        end
      end
  end

  def drive
    # Preload API definitions
    client = Google::APIClient.new
    # handle possible callback from OAuth2 consent page.
    if params[:code]
      authorize_code(params[:code])
    elsif params[:error] # User denied the oauth grant
      halt 403
    end

  end


  ##
  # Exchanges the authorization code to fetch an access
  # and refresh token. Stores the retrieved tokens in the session.
  def authorize_code(code)
    api_client = Google::APIClient.new
    api_client.authorization.client_id = ENV['GOOGLE_ID']
    api_client.authorization.client_secret = ENV['GOOGLE_SECRET']
    api_client.authorization.scope = ENV['GOOGLE_SCOPE']
    api_client.authorization.redirect_uri = ENV['REDIRECT_URI']
    api_client.authorization.code = code
    api_client.authorization.fetch_access_token!
    return api_client
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'You have successfully signed out.'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}."
  end



end
