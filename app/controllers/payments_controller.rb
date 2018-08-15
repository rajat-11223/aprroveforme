class PaymentsController < ApplicationController
  def new
    authorize! :create, Subscription.new(user: current_user)
    @amount = calculate_amount

    if Subscription.exist?(user_id: current_user.id)
      if session[:upgrade] == "upgrade"
        current_user.reload

        session[:degrade] = "degrade" if (current_user.subscription.plan_type == "unlimited")
      else
        redirect_to root_url
      end
    end
  end

  def confirm
    authorize! :update, current_user.subscription

    @amount = calculate_amount
    @result = Braintree::TransparentRedirect.confirm(request.query_string)

    if @result.success?
      if session[:upgrade] == "upgrade"
        current_user.reload

        current_user.subscription.update_attributes! plan_type: session[:plan_type],
                                                     plan_date: Date.today
        session.delete(:plan_type)
        session.delete(:upgrade)

        msg =
          if session.delete(:degrade) != "degrade"
            'Congratulations, you have successfully updated your plan.'
          else
            'Congratulations, you have successfully downgraded your plan.'
          end

        redirect_to root_url, notice: msg
      else
        current_user.reload
        current_user.subscription.update_attributes! plan_type: session[:plan_type], plan_date: Date.today

        SubscriptionHistory.create!(user: current_user, plan_type: session[:plan_type], plan_date: Date.today)
        session[:plan_type] = nil

        redirect_to root_url
      end
    else

      render action: "new"
    end
  end

  protected

  def calculate_amount
    # in a real app this be calculated from a shopping cart, determined by the product, etc.
    case session[:plan_type]
    when "free"
      "0.00"
    when "professional"
      "1.99"
    else
      "4.99"
    end
  end
end
