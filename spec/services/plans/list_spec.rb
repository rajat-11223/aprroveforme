require "rails_helper"

describe Plans::List do
  let(:list) { Plans::List.new }

  it "loads and populates yaml" do
    expect(list).to be_present
    expect(list[SubscriptionHistory::LITE]).to include("name")
    expect(list[SubscriptionHistory::LITE]).to include("monthly")
    expect(list[SubscriptionHistory::LITE]).to include("yearly")
  end

  it "orders plans" do
    expect(list.ordered[0].first).to eq(SubscriptionHistory::LITE)
    expect(list.ordered[1].first).to eq(SubscriptionHistory::PROFESSIONAL)
    expect(list.ordered[2].first).to eq(SubscriptionHistory::UNLIMITED)
  end

  context "when singleton" do
    it "loads and populates yaml" do
      list = Plans::List
      expect(list).to be_present
      expect(list[SubscriptionHistory::LITE]).to include("name")
      expect(list[SubscriptionHistory::LITE]).to include("monthly")
      expect(list[SubscriptionHistory::LITE]).to include("yearly")
    end
  end
end
