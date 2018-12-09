using FindItem

class UsersController < ApplicationController
  def edit
    @user = User.find(params[:id])
    authorize! :edit, @user
  end

  def update
    @user = User.find(params[:id])
    authorize! :update, @user

    name = user_params[:name].presence || [user_params[:first_name], user_params[:last_name]].join(" ")

    if @user.update_attributes!(user_params.merge(name: name))
      redirect_to root_url, notice: "Successfully updated user"
    else
      render :edit
    end
  end

  def show
    @user = User.find(params[:id])
    authorize! :read, @user
  end

  private

  def user_params
    params.require(:user).permit(:provider, :uid, :name, :email, :picture, :token, :first_name, :last_name, :second_email, :customer_id)
  end
end
