require "rails_helper"

describe "EmailProcessor - not supported triggers" do
  include EmailProcessorHelpers

  let(:subject) { EmailProcessor.new(email) }
  let!(:to_user) { to_service("status") }
  let(:email) { build_email(to: [to_user], from: from_user) }
  around { |example| set_to_test_adapter(example) }

  context "when signed up" do
    let!(:from_user) { create(:user) }

    it "not blow up" do
      expect { subject.process }.not_to raise_error
    end

    it "should enqueue a email status job" do
      expect {
        subject.process
      }.to have_enqueued_job(ActionMailer::DeliveryJob).with("EmailFlow::StatusMailer", "update", "deliver_now", from_user)
    end
  end

  context "when not signed up" do
    let!(:from_user) { build_stubbed(:user) }

    it "should NOT enqueue a email status job" do
      expect {
        subject.process
      }.to_not have_enqueued_job(ActionMailer::DeliveryJob).with("EmailFlow::StatusMailer", "update", "deliver_now", from_user)
    end
  end
end
