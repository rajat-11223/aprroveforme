require 'rails_helper'

describe Subscription do
  subject { create(:user, :with_subscription) }

  it 'valid' do
    expect(subject.subscription).to be_valid
  end

  it "requires a user" do
    subject.subscription.user = nil
    expect(subject.subscription).to_not be_valid
  end

  it "requires a plan_type" do
    subject.subscription.plan_type = nil

    expect(subject.subscription).to_not be_valid
  end

  it "requires a plan_date" do
    subject.subscription.plan_date = nil

    expect(subject.subscription).to_not be_valid
  end
end
