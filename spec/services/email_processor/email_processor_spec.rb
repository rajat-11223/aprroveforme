require "rails_helper"

describe EmailProcessor do
  include EmailProcessorHelpers

  let(:email) { build_email }
  let(:subject) { EmailProcessor.new(email) }

  it "processes an email" do
    expect { subject.process }.not_to raise_error
  end

  context "when signed up" do
    let!(:from_user) { create(:user) }
    let!(:to_user) { create(:user) }
    let(:email) { build_email(to: [to_user], from: from_user) }

    it "not blow up" do
      expect { subject.process }.not_to raise_error
    end
  end
end
