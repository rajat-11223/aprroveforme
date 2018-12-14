class AccountsController < ApplicationController
  before_action :require_user!
  skip_before_action :verify_authenticity_token, only: [:add_new_payment_method]

  def profile
    authorize! :read, current_user
  end

  def profile_update
    authorize! :update, current_user

    if current_user.update_attributes(params.permit(:time_zone))
      redirect_to profile_account_path(current_user), notice: "Successfully updated timezone"
    else
      redirect_to profile_account_path(current_user), notice: "Timezone did not update"
    end
  end

  def payment_methods
    authorize! :read, current_user
    @customer = current_user.payment_customer
  end

  def add_new_payment_method
    authorize! :create, current_user.subscription

    PaymentGateway::SyncCustomer.new(current_user).call
    PaymentGateway::AddCard.new(current_user).call(source: params[:stripeToken])

    redirect_to payment_methods_account_path, notice: "Payment method was successfully added."
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
