require 'rails_helper'

describe SubscriptionHistory do
  subject { create(:subscription_history) }

  it 'valid' do
    expect(subject).to be_valid
  end

  it "requires a user" do
    subject.user = nil
    expect(subject).to_not be_valid
  end

  it "requires a plan_type" do
    subject.plan_type = nil

    expect(subject).to_not be_valid
  end

  it "requires a plan_date" do
    subject.plan_date = nil

    expect(subject).to_not be_valid
  end
end
