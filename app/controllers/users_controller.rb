class UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :correct_user?, :except => [:index]
  helper_method :sort_column, :sort_direction

  def index
    unless current_user.has_role? :admin
      redirect_to root_url, :alert => "Access denied."
    end  
      @users = User.order(sort_column + " " + sort_direction).page params[:page]
      @users_all = User.order(:updated_at)
    respond_to do |format|
      format.html
      format.csv { send_data @users_all.to_csv }
      format.xls # { send_data @users.to_csv(col_sep: "\t") }
    end

  end

    def edit
    @user = User.find(params[:id])
  end
  
  def update
    @user = User.find(params[:id])
    if @user.update_attributes(user_params)
      @user.name = "#{@user.first_name} #{@user.last_name}"
      @user.save
      redirect_to root_url
    else
      render :edit
    end
  end


  def show
    @user = User.find(params[:id])
  end

  private
  
  def sort_column
    User.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end
  
  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end
  
  def user_params
    params.require(:user).permit(:provider, :uid, :name, :email, :picture, :token, :first_name, :last_name, :code, :second_email, :customer_id)
  end
  

end
