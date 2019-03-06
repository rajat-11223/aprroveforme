require "rails_helper"

describe WelcomeMailer do
  context "when new user email" do
    let(:user) { create(:user, first_name: "John", email: "john@test.com") }

    it "sends email" do
      email = WelcomeMailer.new_user(user: user)

      expect(email.subject).to eq("[AFM] Welcome to ApproveForMe")
      expect(email.to).to eq(["john@test.com"])
      expect(email.from).to eq(["team@approveforme.com"])

      expect(email.body.encoded).to include("Welcome")
    end
  end
end
