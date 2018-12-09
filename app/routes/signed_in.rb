class SignedIn
  def initialize(&block)
    @block = block || lambda { |user| true }
  end

  def matches?(request)
    @request = request
    signed_in?
  end

  private

  def session_user_id
    @request.session[:user_id]
  end

  def current_user
    User.find_by(id: session_user_id)
  end

  def current_user_fulfills_additional_requirements?
    @block.call current_user
  end

  def signed_in?
    session_user_id.present? && current_user.present?
  end
end
