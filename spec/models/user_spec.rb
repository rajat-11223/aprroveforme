require 'spec_helper'

describe User do
	let!(:user) { User.create }
	subject { user }

  	it {should_not be_valid}

  	it "only has a picture" do
  		user.picture = "https://lh4.googleusercontent.com/-AU_9Qx9sUXw/AAAAAAAAAAI/AAAAAAAAAAA/hXcwDv3KdZI/photo.jpg"
  		user.should_not be_valid
  	end

  	it "only has an email" do
  		user.email = "kimmanis@gmail.com"
  		user.should_not be_valid
  	end

  	it "has a picture and an email" do
  		user.picture = "https://lh4.googleusercontent.com/-AU_9Qx9sUXw/AAAAAAAAAAI/AAAAAAAAAAA/hXcwDv3KdZI/photo.jpg"
  		user.email = "kimmanis@gmail.com"
  		should be_valid
  	end

  	pending "asks the user for her name if it doesn't exist"

end
