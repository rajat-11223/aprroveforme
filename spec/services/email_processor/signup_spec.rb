require "rails_helper"

describe "EmailProcessor - signup@" do
  include EmailProcessorHelpers

  let(:subject) { EmailProcessor.new(email) }
  let!(:to_user) { to_service("signup") }
  let(:email) { build_email(to: [to_user], from: from_user) }

  context "when not signed up" do
    let!(:from_user) { build_stubbed(:user) }

    it "should enqueue a sign up email job" do
      expect {
        subject.process
      }.to have_enqueued_job(ActionMailer::DeliveryJob).with("EmailFlow::SignupMailer", "signup", "deliver_now", from_user.email)
    end
  end

  context "when signed up" do
    let!(:from_user) { create(:user) }

    it "should not enqueue a sign up email job" do
      expect {
        subject.process
      }.to_not have_enqueued_job(ActionMailer::DeliveryJob).with("EmailFlow::SignupMailer", "signup", "deliver_now", from_user.email)
    end
  end
end
