class SubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  before_action :disable_turbolinks_cache, only: [:new]

  def new
    session[:plan_name] = params[:plan_name]
    session[:plan_interval] = params[:plan_interval]

    authorize! :create, current_user.subscription

    if current_user.payment_customer? &&
        !PaymentGateway::FetchCards.new(current_user).call.empty?
          current_user.subscription.plan_name != "lite"
      update
    end
  end

  def continue_permission
    authorize! :create, current_user.subscription
    render partial: 'continue_permission', locals: { name: params[:name], interval: params[:interval] }
  end

  def create
    authorize! :create, current_user.subscription

    plan_name = params.require(:plan_name)
    plan_interval = params.require(:plan_interval)

    SubscriptionHistory.transaction do
      customer = fetch_or_create_customer

      PaymentGateway::CreateSubscription.new(user).call(name: plan_name,
                                                        interval: plan_interval)
    end

    redirect_to root_url, notice: "We have successfully changed your plan to #{plan_name}."
  end

  def update
    authorize! :create, current_user.subscription

    plan_name = params.require(:plan_name)
    plan_interval = params.require(:plan_interval)

    SubscriptionHistory.transaction do
      customer = fetch_or_create_customer

      PaymentGateway::UpdateSubscription.new(current_user).call(name: plan_name,
                                                                interval: plan_interval)
    end

    session.delete(:plan_name)
    session.delete(:plan_interval)
    session.delete(:upgrade)
    session.delete(:degrade)

    redirect_to root_url, notice: "We have successfully changed your plan to #{plan_name}, being billed #{plan_interval}."
  end

  protected

  def fetch_or_create_customer
    @customer ||=
      if current_user.payment_customer?
        PaymentGateway::SyncCustomer.new(current_user).call
      else
        PaymentGateway::CreateCustomer.new(current_user).call
      end
  end
end
