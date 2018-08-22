class PricingController < ApplicationController
  skip_authorization_check

  before_action :disable_turbolinks_cache

  def index
    session[:upgrade] = params[:type]
    @client_token = current_user
    @plans = Braintree::Plan.all
  end
end
