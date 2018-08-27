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

  it "requires a plan_name" do
    subject.plan_name = nil

    expect(subject).to_not be_valid
  end

  it "requires a plan_interval" do
    subject.plan_interval = nil

    expect(subject).to_not be_valid
  end

  it "requires a plan_identifier" do
    subject.plan_identifier = nil

    expect(subject).to_not be_valid
  end

  it "requires a subscription_identifier" do
    subject.subscription_identifier = nil

    expect(subject).to_not be_valid
  end

  it "requires a plan_date" do
    subject.plan_date = nil

    expect(subject).to_not be_valid
  end
end
