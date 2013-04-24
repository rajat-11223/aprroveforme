module ApproverHelper

	# takes in the email address and returns the gravatar URL
	def image_url(email)
		"http://www.gravatar.com/avatar/#{Digest::MD5.hexdigest(email.downcase.strip)}"
	end

end
