class PaymentsController < ApplicationController
  def new
    raise "where is this called?"
    # authorize! :create, current_user.subscription
    #
    # if current_user.subscription.present?
    #   if session[:upgrade] == "upgrade"
    #     session[:degrade] = "degrade" if (current_user.subscription.plan_type == "unlimited")
    #   else
    #     redirect_to root_url
    #   end
    # end
  end
end
