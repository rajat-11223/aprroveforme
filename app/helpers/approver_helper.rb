module ApproverHelper

	# takes in the email address and returns the gravatar URL
	def image_url(email)
		user = User.where("email = ?", email).first
		if user && user.picture && user.picture != ""
			user.picture
		else
			"http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase.strip)}?d=mm"

		end
	end

end
