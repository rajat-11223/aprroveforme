class PricingController < ApplicationController
  def index
  	 session[:upgrade]=params[:type]
  end
end
