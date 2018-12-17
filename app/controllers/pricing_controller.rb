class PricingController < ApplicationController
  skip_authorization_check
  before_action :disable_turbolinks_cache

  def index
  end
end
