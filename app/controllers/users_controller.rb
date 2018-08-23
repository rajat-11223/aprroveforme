using FindItem

class UsersController < ApplicationController
  helper_method :sort_column, :sort_direction

  def index
    authorize! :manage, :all

    respond_to do |format|
      format.html { @users = User.order(sort_column => sort_direction).page(params[:page]) }
      format.csv { send_data User.to_csv }
    end
  end

  def edit
    @user = User.find(params[:id])
    authorize! :edit, @user
  end

  def update
    @user = User.find(params[:id])
    authorize! :update, @user

    name = user_params[:name].presence ||
            [user_params[:first_name], user_params[:last_name]].join(" ")

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

  def sort_column
    @sort_column ||=
      User.column_names.find_item(params[:sort]) || "name"
  end

  def sort_direction
    @sort_direction ||=
      %w[asc desc].find_item(params[:direction]) || "asc"
  end

  def user_params
    params.require(:user).permit(:provider, :uid, :name, :email, :picture, :token, :first_name, :last_name, :code, :second_email, :customer_id)
  end
end
