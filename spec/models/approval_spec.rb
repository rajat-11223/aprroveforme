require 'spec_helper'

describe Approval do
	let!(:approval) { Approval.create }
	subject { approval }

	it {should_not be_valid}

	it "only has a title" do
		approval.title = "test title"
		approval.should_not be_valid
	end

	it "has a title, deadline and file" do
		approval.title = "test title"
		approval.deadline = Time.now.to_datetime
		approval.link = "www.google.com"
		approval.should_not be_valid
	end

	it "has an approver, title, deadline and file" do
		approval.approvers << Approver.new(name: "Kim", email: "kimmanis@gmail.com")
		approval.title = "test title"
		approval.deadline = Time.now.to_datetime
		approval.link = "www.google.com"
		approval.should be_valid
	end


  pending "has at least one approver"


end
