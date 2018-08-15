class PricingController < ApplicationController
  skip_authorization_check
  include ApplicationHelper

  def index
    session[:upgrade] = params[:type]
    @client_token = current_user
    @plans = Braintree::Plan.all
  end
end
