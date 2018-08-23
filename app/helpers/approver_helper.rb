module ApproverHelper

  # takes in the email address and returns the gravatar URL
  def image_url(email)
    user = User.find_by(email: email)

    if user && user.picture.present?
      user.picture
    else
      GravatarUrl.generate(email)
    end
  end
end
