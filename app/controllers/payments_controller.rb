class PaymentsController < ApplicationController
  def new
    if !Subscription.all.collect(&:user_id).include? current_user.id
      @amount = calculate_amount
    else
      if session[:upgrade]== "upgrade"
       if  Subscription.find_by_user_id(current_user.id).plan_type == "unlimited"
        session[:degrade]="degrade"
       end 
        @amount = calculate_amount
      else
      redirect_to root_url
      end
    end  
  end

  def confirm
    
    @result = Braintree::TransparentRedirect.confirm(request.query_string)
    if @result.success?

      if session[:upgrade]== "upgrade"
        @subscription=Subscription.find_by_user_id(current_user.id)
        @subscription.plan_type= session[:plan_type]
        @subscription.plan_date= Date.today
        @subscription.save
        session[:plan_type]=nil
        session[:upgrade]=nil
        respond_to do |format|
          if session[:degrade]!="degrade"
            format.html { redirect_to root_url, notice: 'Congratulations, you have successfully updated your plan.' }
          else
            session[:degrade]=nil
            format.html { redirect_to root_url, notice: 'Congratulations, you have successfully downgraded your plan.' } 
          end
        end
      else  
        Subscription.create(:plan_type=>session[:plan_type],:plan_date=> Date.today,:user_id=> current_user.id)
        session[:plan_type]=nil
        redirect_to root_url
      end
    else
      @amount = calculate_amount
      render :action => "new"
    end
  end

  protected

  def calculate_amount
    # in a real app this be calculated from a shopping cart, determined by the product, etc.
    if session[:plan_type]=="free"
    "00.00"
    elsif session[:plan_type] == "professional"
    "1.00"
    else
    "19.00"
  end
  end
end
