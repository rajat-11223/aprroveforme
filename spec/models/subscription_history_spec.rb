# == Schema Information
#
# Table name: subscription_histories
#
#  id                      :integer          not null, primary key
#  plan_date               :datetime
#  plan_identifier         :string           not null
#  plan_interval           :string           not null
#  plan_name               :string           not null
#  renewable_date          :datetime
#  subscription_identifier :string           not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  user_id                 :integer
#
# Indexes
#
#  index_subscription_histories_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#

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
