require "rails_helper"
require "cancan/matchers"

describe "Abilities" do
  subject(:ability) { Ability.new(user) }
  let(:user){ nil }
  let(:other_user) { create(:user, name: "Other User") }
  let(:other_approval) { create(:approval, owner: other_user.id) }

  context "when is guest" do
    let(:user){ nil }

    it { expect_to_be_able_to(:read, :homepage) }
    it { expect_to_not_be_able_to(:read, other_user) }
    it { expect_to_not_be_able_to(:read, other_approval) }
  end

  context "when is admin" do
    let(:user){ create(:user, :admin) }

    it { expect_to_be_able_to(:read, user) }

    it { expect_to_be_able_to(:read, other_user) }
    it { expect_to_be_able_to(:edit, other_user) }
    it { expect_to_be_able_to(:destroy, other_user) }

    it { expect_to_be_able_to(:read, other_approval) }
    it { expect_to_be_able_to(:edit, other_approval) }
    it { expect_to_be_able_to(:destroy, other_approval) }
  end

  context "when standard user" do
    let(:user){ create(:user) }
    let(:approval) { create(:approval, owner: user.id)}
    let(:subscription) { create(:subscription, user: user) }
    let(:subscription_history) { create(:subscription_history, user: user) }

    it { expect_to_be_able_to(:read, user) }
    it { expect_to_be_able_to(:update, user) }

    it { expect_to_not_be_able_to(:read, other_user) }
    it { expect_to_not_be_able_to(:update, other_user) }
    it { expect_to_not_be_able_to(:destroy, other_user) }

    it { expect_to_be_able_to(:create, approval) }
    it { expect_to_be_able_to(:read, approval) }
    it { expect_to_be_able_to(:update, approval) }

    it { expect_to_not_be_able_to(:read, other_approval) }
    it { expect_to_not_be_able_to(:update, other_approval) }
    it { expect_to_not_be_able_to(:destroy, other_approval) }

    it { expect_to_be_able_to(:read, subscription) }
    it { expect_to_be_able_to(:create, subscription) }
    it { expect_to_be_able_to(:update, subscription) }
    it { expect_to_not_be_able_to(:destroy, subscription) }

    it { expect_to_be_able_to(:read, subscription_history) }
    it { expect_to_not_be_able_to(:create, subscription_history) }
    it { expect_to_not_be_able_to(:update, subscription_history) }
    it { expect_to_not_be_able_to(:destroy, subscription_history) }
  end

  def expect_to_be_able_to(perm, model)
    should be_able_to(perm, model)
  end

  def expect_to_not_be_able_to(perm, model)
    should_not be_able_to(perm, model)
  end
end
