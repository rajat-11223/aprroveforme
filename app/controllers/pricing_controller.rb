class PricingController < ApplicationController
  include ApplicationHelper
  def index
  	 session[:upgrade]=params[:type]
  	 @client_token = current_user
  end
end
