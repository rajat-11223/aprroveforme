class AccountsController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:add_new_payment_method]

  def profile; end

  def payment_methods
    @customer = Braintree::Customer.find(current_user.customer_id)
  end

  def add_new_payment_method
    result = Braintree::Customer.update(
        current_user.customer_id,
        first_name: current_user.first_name,
        last_name: current_user.last_name,
        payment_method_nonce: params[:payment_method_nonce]
    )
    if result.success?
      redirect_to payment_methods_account_path, notice: 'PaymentMethod is successfully added'
    else
      redirect_to payment_methods_account_path, notice: 'Something went wrong please try again'
    end
  end

  def delete_payment_method
    Braintree::PaymentMethod.delete(params[:id])
    redirect_to payment_methods_account_path, notice: 'PaymentMethod is successfully deleted'
  end

  def set_default_payment_method
    result = Braintree::PaymentMethod.update(
        params[:id],
        :options => {
            :make_default => true
        }
    )
    redirect_to payment_methods_account_path, notice: 'PaymentMethod info is successfully updated'
  end

  def update_card; end

  def update_card_post
    customer = Braintree::Customer.find(current_user.customer_id)

    @result = Braintree::CreditCard.update(customer.credit_cards.first.token,
                                           :cvv => params[:cvv],
                                           :number => params[:number],
                                           :expiration_date => params[:expiration_date],
                                           :options => {:verify_card => true}
    )

    puts customer
    if @result.success?
      redirect_to payment_methods_account_path, notice: 'Card is successfully updated'
    else
      redirect_to update_card_account_path, notice: 'Please provide correct information to continue'
    end
  end

  def active_approvals
    @my_approvals = Approval.where("owner = ? and deadline >= ?", current_user.id, Date.today+1)
  end

  def completed_approvals
    @my_completed_approvals = Approval.where("owner = ? and deadline < ?", current_user.id, Date.today+1)
  end

  def pending_approvars
    @pending_approvals = Approver.where("(email = ? or email = ? ) and (status = ? or status = ?)", current_user.email.downcase, current_user.second_email, "Pending", "")
  end

  def signed_off_approvars
    @signedoff_approvals = Approver.where("(email = ? or email = ? ) and (status = ? or status = ?)", current_user.email.downcase, current_user.second_email, "Approved", "Declined")
  end

  def all_approvars
    @any_approvers = Approver.where("email = ? or email = ? ", current_user.email.downcase, current_user.second_email)
  end

  def current_subscription; end

  def subscription_histories
    @subscription_histories = current_user.subscription_histories
  end
end
