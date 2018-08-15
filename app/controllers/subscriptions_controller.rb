require "braintree"

class SubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token

  def new
    session[:plan_type] = params[:plan_type]
    @amount = calculate_amount

    authorize! :create, current_user.subscription

    if current_user.customer_id?
      customer = Braintree::Customer.find(current_user.customer_id)
      if customer.payment_methods.present? and current_user.subscription.plan_type != 'free'
        upgrade
      end
    end
  end

  def continue_permission
    authorize! :create, current_user.subscription
    render partial: 'continue_permission', locals: { plan: params[:id] }
  end

  def create
    authorize! :create, current_user.subscription

    plan_type = session[:plan_type]
    Subscription.transaction do
      braintree_customer = fetch_or_create_braintree_customer

      # Create subscription for user
      payment_method_token = braintree_customer.payment_methods.find{ |pm| pm.default? }.token
      braintree_subscription = Braintree::Subscription.create!(
        payment_method_token: payment_method_token,
        price: calculate_amount,
        plan_id: plan_type,
        options: {
          start_immediately: true
        }
      )

      current_user.update_attributes! braintree_subscription_id: braintree_subscription.id

      # subscription history
      current_user.subscription_histories.create!(plan_type: plan_type, plan_date: Time.new)
    end

    redirect_to root_url, notice: "We have successfully changed your plan to #{plan_type}."
  end

  def upgrade
    authorize! :create, current_user.subscription

    plan_type = params.require(:plan_type)

    Subscription.transaction do
      braintree_customer = fetch_or_create_braintree_customer
      braintree_subscription = fetch_or_create_braintree_subscription(customer: braintree_customer, plan_type: plan_type)

      # Create subscription history
      current_user.subscription_histories.create!(plan_type: plan_type, plan_date: Time.now)
    end

    session.delete(:plan_type)
    session.delete(:upgrade)
    session.delete(:degrate)

    redirect_to root_url, notice: "We have successfully changed your plan to #{plan_type}."
  rescue Braintree::NotFoundError => e
    Rollbar.error(e)
    redirect_to root_url, notice: e.message
  end

  protected

  def fetch_or_create_braintree_customer
    @customer ||=
      begin
        result =
          if current_user.customer_id?
            Braintree::Customer.update(current_user.customer_id,
                                       first_name: current_user.first_name,
                                       last_name: current_user.last_name,
                                       payment_method_nonce: params[:payment_method_nonce])

          else
            Braintree::Customer.create(email: current_user.email,
                                       first_name: current_user.first_name,
                                       last_name: current_user.last_name,
                                       payment_method_nonce: params[:payment_method_nonce])
          end

        result.customer.tap do |customer|
          current_user.update_attributes(customer_id: customer.id)
        end
      end
  end

  def fetch_or_create_braintree_subscription(customer:, plan_type:)
    payment_method_token = customer.payment_methods.find { |pm| pm.default? }.token

    subscription =
      if current_user.braintree_subscription_id?
        Braintree::Subscription.update!(
          current_user.braintree_subscription_id,
          payment_method_token: payment_method_token,
          plan_id: plan_type,
          price: calculate_amount,
          options: {
            prorate_charges: true
          })
      else
        Braintree::Subscription.create!(payment_method_token: payment_method_token,
                                        plan_id: plan_type,
                                        price: calculate_amount,
                                        options: {
                                          start_immediately: true
                                        })
      end

    subscription.tap do |subscription|
      current_user.update(braintree_subscription_id: subscription.id)
    end

  rescue Braintree::NotFoundError => e
    Rollbar.error(e)
    redirect_to root_url, notice: e.message
  end

  def calculate_amount
    case params[:plan_type]
    when "free"
      "00.00"
    when "professional"
      "1.99"
    else
      "4.99"
    end
  end
end
