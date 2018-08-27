require "spec_helper"

describe Plans::List do
  let(:list) { Plans::List.new }

  it 'loads and populates yaml' do
    expect(list).to be_present
    expect(list["lite"]).to include("name")
    expect(list["lite"]).to include("monthly")
    expect(list["lite"]).to include("yearly")
  end

  it 'orders plans' do
    expect(list.ordered[0].first).to eq("lite")
    expect(list.ordered[1].first).to eq("professional")
    expect(list.ordered[2].first).to eq("unlimited")
  end

  context "when singleton" do
    it 'loads and populates yaml' do
      list = Plans::List
      expect(list).to be_present
      expect(list["lite"]).to include("name")
      expect(list["lite"]).to include("monthly")
      expect(list["lite"]).to include("yearly")
    end
  end
end
