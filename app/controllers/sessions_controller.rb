class SessionsController < ApplicationController

  def new
    redirect_to '/auth/google_oauth2'
  end


  def create
    puts params
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

  def destroy
    reset_session
    redirect_to root_url, :notice => 'You have successfully signed out.'
  end

  def failure
    redirect_to root_url, :alert => "Authentication error: #{params[:message].humanize}."
  end

end
