require "rails_helper"

describe WelcomeMailer do
  let(:user) { build_stubbed(:user, first_name: "John", name: "John Smith", email: "john@test.com") }

  context "when new user email" do
    let(:email) { WelcomeMailer.new_user(user: user) }

    it "sends email" do
      expect(email.subject).to eq("[AFM] Welcome to ApproveForMe")
      expect(email.to).to eq(["john@test.com"])
      expect(email.from).to eq(["team@approveforme.com"])

      expect(email.body.encoded).to include("Welcome")
    end
  end

  context "when one day out user email" do
    let(:email) { WelcomeMailer.day_one(user: user) }

    it "sends email" do
      expect(email.subject).to include("[AFM]")
      expect(email.to).to eq(["john@test.com"])
      expect(email.from).to eq(["team@approveforme.com"])

      expect(email.body.encoded).to include("Welcome John Smith,")
    end
  end

  context "when three day out user email" do
    let(:email) { WelcomeMailer.day_three(user: user) }

    it "sends email" do
      expect(email.subject).to include("[AFM]")
      expect(email.to).to eq(["john@test.com"])
      expect(email.from).to eq(["team@approveforme.com"])

      expect(email.body.encoded).to include("Hi John Smith,")
    end
  end

  context "when seven day out user email" do
    let(:email) { WelcomeMailer.day_seven(user: user) }

    it "sends email" do
      expect(email.subject).to include("[AFM]")
      expect(email.to).to eq(["john@test.com"])
      expect(email.from).to eq(["team@approveforme.com"])

      expect(email.body.encoded).to include("Hey John Smith,")
    end
  end
end
