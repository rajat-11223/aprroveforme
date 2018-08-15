class SubscriptionsController < ApplicationController
  skip_before_action :verify_authenticity_token
  require "braintree"

  def new
    session[:plan_type] = params[:plan_type]
    @amount = calculate_amount

    authorize! :edit, Subscription.new(user: current_user)

    if current_user.customer_id?
      customer = Braintree::Customer.find(current_user.customer_id)
      if customer.payment_methods.present? and current_user.subscription.plan_type != 'free'
        upgrade
      end
    end
  end

  def continue_permission
    authorize! :create, Subscription.new(user: current_user)
    render partial: 'continue_permission', locals: { plan: params[:id] }
  end

  def create
    authorize! :create, Subscription.new(user: current_user)

    if current_user.customer_id?
      Braintree::Customer.update(
        current_user.customer_id,
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        payment_method_nonce: params[:payment_method_nonce]
      )

      customer = Braintree::Customer.find(current_user.customer_id)
      current_user.update(customer_id: customer.id)
    else
      result = Braintree::Customer.create(
        email: current_user.email,
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        payment_method_nonce: params[:payment_method_nonce]
      )
      customer = result.customer
      current_user.update(customer_id: customer.id)
    end

    result = Braintree::Subscription.create(
      payment_method_token: customer.payment_methods.find{ |pm| pm.default? }.token,
      plan_id: params[:plan_id],
      :options => {
        :start_immediately => true
      }
    )

    current_user.update(braintree_subscription_id: result.subscription.id)

    if session[:upgrade] == "upgrade"
      @subscription = Subscription.find_by(user_id: current_user.id)
      @subscription.plan_type = session[:plan_type]
      @subscription.plan_date = Date.today
      @subscription.save

      # subscription history
      SubscriptionHistory.create!(plan_type: session[:plan_type], plan_date: Time.now, user: current_user)

      session[:plan_type] = nil
      session[:upgrade] = nil

      if session[:degrade] != "degrade"
        redirect_to root_url, notice: 'Congratulations, you have successfully updated your plan.'
      else
        session[:degrade] = nil
        redirect_to root_url, notice: 'Congratulations, you have successfully downgraded your plan.'
      end
    end

  end

  def upgrade
    authorize! :update, current_user.subscription

    if current_user.customer_id?
      Braintree::Customer.update(
          current_user.customer_id,
          first_name: current_user.first_name,
          last_name: current_user.last_name
      )

      customer = Braintree::Customer.find(current_user.customer_id)

    else
      result = Braintree::Customer.create(
          email: current_user.email,
          first_name: current_user.first_name,
          last_name: current_user.last_name,
          payment_method_nonce: params[:payment_method_nonce]
      )
      customer = result.customer
      current_user.update(customer_id: customer.id)
    end

    begin
      result = Braintree::Subscription.update(
          current_user.braintree_subscription_id,
          payment_method_token: customer.payment_methods.find{ |pm| pm.default? }.token,
          id: SecureRandom.uuid,
          plan_id: params[:plan_type],
          :price => calculate_amount

      )

    current_user.update(braintree_subscription_id: result.subscription.id)

    if session[:upgrade] == "upgrade"
      @subscription=Subscription.find_by_user_id(current_user.id)
      @subscription.plan_type= session[:plan_type]
      @subscription.plan_date= Date.today
      @subscription.save

      # subscription history
      SubscriptionHistory.create(plan_type: session[:plan_type], plan_date: Time.now )

      session[:plan_type] = nil
      session[:upgrade] = nil

      respond_to do |format|
        if session[:degrade] != "degrade"
          format.html { redirect_to root_url, notice: 'Congratulations, you have successfully updated your plan.' }
        else
          session[:degrade]=nil
          format.html { redirect_to root_url, notice: 'Congratulations, you have successfully downgraded your plan.' }
        end
      end
    end

    rescue Braintree::NotFoundError => e
      redirect_to root_url, notice: e.message
    end

  end


  protected

  def calculate_amount
    case session[:plan_type]
    when "free"
      "00.00"
    when "professional"
      "1.99"
    else
      "4.99"
    end
  end
end
