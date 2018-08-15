class PaymentsController < ApplicationController
  def new
    authorize! :create, Subscription.new(user: current_user)

    if !Subscription.exist?(user_id: current_user.id)
      @amount = calculate_amount
    else
      if session[:upgrade]== "upgrade"
        if Subscription.find_by(user_id: current_user.id).plan_type == "unlimited"
          session[:degrade]="degrade"
        end

        @amount = calculate_amount
      else
        redirect_to root_url
      end
    end
  end

  def confirm
    authorize! :update, current_user.subscription

    @result = Braintree::TransparentRedirect.confirm(request.query_string)
    if @result.success?

      if session[:upgrade] == "upgrade"
        @subscription = Subscription.find_by(user_id: current_user.id)
        @subscription.plan_type = session[:plan_type]
        @subscription.plan_date = Date.today
        @subscription.save
        session[:plan_type] = nil
        session[:upgrade] = nil

          if session[:degrade] != "degrade"
            redirect_to root_url, notice: 'Congratulations, you have successfully updated your plan.'
          else
            session[:degrade] = nil
            redirect_to root_url, notice: 'Congratulations, you have successfully downgraded your plan.'
          end
        end
      else
        # Subscription.create!(plan_type: session[:plan_type], plan_date: Date.today, user_id: current_user.id)
        binding.pry
        current_user.subscription.update_attributes! plan_type: session[:plan_type], plan_date: Date.today
        SubscriptionHistory.create!(user: current_user, plan_type: session[:plan_type], plan_date: Date.today)
        session[:plan_type] = nil
        redirect_to root_url
      end
    else
      @amount = calculate_amount
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
