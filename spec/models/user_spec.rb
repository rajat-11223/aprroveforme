# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  approvals_received        :integer
#  approvals_received_30     :integer
#  approvals_responded_to    :integer
#  approvals_responded_to_30 :integer
#  approvals_sent            :integer
#  approvals_sent_30         :integer
#  code                      :string(255)
#  email                     :string(255)
#  email_domain              :string(255)
#  expires                   :boolean
#  expires_at                :datetime
#  first_name                :string(255)
#  last_login_at             :datetime
#  last_name                 :string(255)
#  last_sent_date            :datetime
#  name                      :string(255)
#  picture                   :string(255)
#  provider                  :string(255)
#  refresh_token             :string(255)
#  second_email              :string(255)
#  time_zone                 :string
#  token                     :string(255)
#  uid                       :string(255)
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  customer_id               :string
#  stripe_subscription_id    :string
#

require "rails_helper"

describe User do
  subject { build_stubbed(:user) }

  it { expect(subject).to be_valid }

  it "requires a picture" do
    subject.picture = nil
    expect(subject).to_not be_valid
  end

  it "requires an email" do
    subject.email = nil
    expect(subject).to_not be_valid
  end

  it "does not have a default last_login_at" do
    expect(subject.last_login_at).to be_nil
  end
end
