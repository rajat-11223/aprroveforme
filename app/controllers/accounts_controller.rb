class AccountsController < ApplicationController
  before_action :require_user!
  skip_before_action :verify_authenticity_token, only: [:add_new_payment_method]

  def profile
    authorize! :read, current_user
  end

  def payment_methods
    authorize! :read, current_user
    @customer = Braintree::Customer.find(current_user.customer_id)
  end

  def add_new_payment_method
    authorize! :create, current_user.subscription

    result = Braintree::Customer.update(
      current_user.customer_id,
      first_name: current_user.first_name,
      last_name: current_user.last_name,
      payment_method_nonce: params[:payment_method_nonce]
    )
    if result.success?
      redirect_to payment_methods_account_path, notice: 'Payment method was successfully added.'
    else
      redirect_to payment_methods_account_path, notice: 'Something went wrong please try again.'
    end
  end

  def delete_payment_method
    authorize! :create, current_user.subscription

    Braintree::PaymentMethod.delete(params[:id])
    redirect_to payment_methods_account_path, notice: 'Payment method was successfully deleted.'
  end

  def set_default_payment_method
    authorize! :create, current_user.subscription

    result = Braintree::PaymentMethod.update(
      params[:id],
      options: {
        make_default: true
      }
    )

    redirect_to payment_methods_account_path, notice: 'PaymentMethod info is successfully updated'
  end

  def update_card
    authorize! :create, current_user.subscription
  end

  def update_card_post
    authorize! :create, current_user.subscription
    customer = Braintree::Customer.find(current_user.customer_id)

    @result = Braintree::CreditCard.update(customer.credit_cards.first.token,
                                           cvv: params[:cvv],
                                           number: params[:number],
                                           expiration_date: params[:expiration_date],
                                           options: {verify_card: true}
    )

    if @result.success?
      redirect_to payment_methods_account_path, notice: 'Card is successfully updated'
    else
      redirect_to update_card_account_path, notice: 'Please provide correct information to continue'
    end
  end

  def current_subscription
    @subscription = current_user.subscription
    @subscription_histories = current_user.subscription_histories

    authorize! :read, @subscription
  end
end
