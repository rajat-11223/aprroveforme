require "rails_helper"

describe "EmailProcessor - not supported triggers" do
  include EmailProcessorHelpers

  let(:subject) { EmailProcessor.new(email) }
  let!(:to_user) { to_service("some-words") }
  let(:email) { build_email(to: [to_user], from: from_user) }

  context "when not signed up" do
    let!(:from_user) { build_stubbed(:user) }

    it "should enqueue a not signed up email job" do
      expect {
        subject.process
      }.to have_enqueued_job(ActionMailer::DeliveryJob).with("EmailFlow::SignupMailer", "how_to_signup", "deliver_now", from_user.email)
    end
  end

  context "when signed up" do
    let!(:from_user) { create(:user) }

    it "should not enqueue any job" do
      expect {
        subject.process
      }.to_not have_enqueued_job
    end
  end
end
