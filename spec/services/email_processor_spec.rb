require "spec_helper"

describe EmailProcessor do
  let(:email) { build_email }
  let(:subject) { EmailProcessor.new(email) }

  it "processes an email" do
    expect { subject.process }.not_to raise_error
  end

  context "when not signed up" do
    let!(:from_user) { build_stubbed(:user) }
    let!(:to_user) { build_stubbed(:user, email: "some-words@mail.approveforme.com") }
    let(:email) { build_email(to: [to_user], from: from_user) }

    it "should enqueue a not signed up email job" do
      expect {
        subject.process
      }.to have_enqueued_job(ActionMailer::DeliveryJob).with("EmailFlow::SignupMailer", "how_to_signup", "deliver_now", from_user.email)
    end
  end

  context "when signed up" do
    let!(:from_user) { create(:user) }
    let!(:to_user) { create(:user) }
    let(:email) { build_email(to: [to_user], from: from_user) }

    it "not blow up" do
      expect { subject.process }.not_to raise_error
    end
  end

  context "when status email" do
    let!(:from_user) { create(:user) }
    let!(:to_user) { build_stubbed(:user, email: "status@mail.approveforme.com") }
    let(:email) { build_email(to: [to_user], from: from_user) }

    it "not blow up" do
      expect { subject.process }.not_to raise_error
    end

    it "should enqueue a email status job" do
      expect {
        subject.process
      }.to have_enqueued_job(ActionMailer::DeliveryJob).with("EmailFlow::StatusMailer", "update", "deliver_now", from_user)
    end
  end

  def build_email(attrs = {})
    details = {}
    if attrs[:to].present?
      attrs[:to].each do |u|
        details[:to] ||= []
        details[:to] << EmailExtractor.new(u).extract
      end
    end

    if attrs[:from].present?
      details[:from] = EmailExtractor.new(attrs[:from]).extract
    end

    build(:email, details)
  end
end

class EmailExtractor
  def initialize(user)
    @user = user
  end

  def extract
    {full: "#{@user.name} <#{@user.email}>", email: @user.email, token: @user.email.split("@").first, host: @user.email.split("@").last, name: @user.name}
  end
end
