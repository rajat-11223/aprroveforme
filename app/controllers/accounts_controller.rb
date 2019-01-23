class AccountsController < ApplicationController
  before_action :require_user!, except: [:need_to_activate, :activate]
  skip_before_action :verify_authenticity_token, only: [:add_new_payment_method]

  def profile
    authorize! :read, current_user
  end

  def need_to_activate
    authorize! :read, current_user
    if request.post?
      flash[:notice] = "Check your email. Welcome email has been resent."

      UserMailer.new_user(current_user.name, current_user.email).deliver_later
    end
  end

  def activate
    authorize! :update, current_user

    current_user.activate!
    redirect_to dashboard_home_index_path, notice: "Your account is now activated."
  end

  def profile_update
    authorize! :update, current_user

    if current_user.update_attributes(params.permit(:time_zone))
      redirect_to profile_account_path, notice: "Successfully updated timezone"
    else
      redirect_to profile_account_path, notice: "Timezone did not update"
    end
  end

  def payment_methods
    session.delete(:plan_name)
    session.delete(:plan_interval)

    authorize! :read, current_user
    @customer = current_user.payment_customer
    @card_data = @customer.sources.data
  end

  def add_new_payment_method
    authorize! :create, current_user.subscription

    PaymentGateway::SyncCustomer.new(current_user).call
    PaymentGateway::AddCard.new(current_user).call(source: params[:stripeToken])

    if session[:plan_name].present? && session[:plan_interval].present?
      name = session.delete(:plan_name)
      interval = session.delete(:plan_interval)

      PaymentGateway::CreateOrUpdateSubscription.new(current_user).call(name: name,
                                                                        interval: interval)

      redirect_to dashboard_home_index_path, notice: "Congratulations! Upgraded to #{name}, billed #{interval}"
    else
      redirect_to payment_methods_account_path, notice: "Payment method was successfully added."
    end
  end

  def delete_payment_method
    authorize! :create, current_user.subscription

    PaymentGateway::RemoveCard.new(current_user).call(token: params[:id])

    redirect_to payment_methods_account_path, notice: "Payment method was successfully deleted."
  end

  def set_default_payment_method
    authorize! :create, current_user.subscription

    PaymentGateway::SetDefaultCard.new(current_user).call(token: params[:id])

    redirect_to payment_methods_account_path, notice: "Default card successfully updated"
  end

  def current_subscription
    @subscription = current_user.subscription
    @subscription_histories = current_user.subscription_histories

    authorize! :read, @subscription
  end
end
