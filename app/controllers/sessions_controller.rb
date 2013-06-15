class SessionsController < ApplicationController

  def new
    redirect_to '/auth/google_oauth2'
  end


  def create
      auth = request.env["omniauth.auth"]
      user = User.where(:provider => auth['provider'], 
                        :uid => auth['uid'].to_s).first || User.create_with_omniauth(auth)
      session[:user_id] = user.id
      session[:credentials] = auth["credentials"]
      user.token = auth["credentials"]["token"] || ""
      user.refresh_token = auth["credentials"]["refresh_token"] if auth["credentials"]["refresh_token"]
      user.code = params["code"] || ""
      user.add_role :admin if User.count == 1 # make the first user an admin
      if user.email.blank?
        redirect_to edit_user_path(user), :alert => "Please enter your email address."
      else
        user.save
        redirect_to root_url
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
    api_client.authorization.code = code
    api_client.authorization.fetch_access_token!
    puts api_client
    auth = api_client
    provider = "google_oauth2"
    user = User.where(:provider => provider, 
                        :uid => auth['uid'].to_s).first || User.create_with_omniauth(auth)
    # put the tokens in the session
    session[:user_id] = user.id
    session[:credentials] = api_client.authorization
    user.token = auth["credentials"]["token"] || ""
    user.refresh_token = auth["credentials"]["refresh_token"] if auth["credentials"]["refresh_token"]
    user.code = params["code"] || ""
    user.save
    redirect_to root_url
  end

  def destroy
    reset_session
    redirect_to root_url, :notice => 'You have successfully signed out.'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}."
  end

  # Exchanges the authorization code to fetch an access
# and refresh token. Stores the retrieved tokens in the session.
def authorize_code(code)
  api_client.authorization.code = code
  api_client.authorization.fetch_access_token!
  # put the tokens in the session
  puts "debugging"
  puts "api client: #{api_client}"
  puts "auth: #{api_client.authorization}"
  session[:access_token] = api_client.authorization.access_token
  session[:refresh_token] = api_client.authorization.refresh_token
  session[:expires_in] = api_client.authorization.expires_in
  session[:issued_at] = api_client.authorization.issued_at
end

end
