require "rails_helper"

describe RequestType do
  before { Rails.application.load_seed }
  let(:approval) { RequestType.find_by(slug: "approval") }
  let(:confirmation) { RequestType.find_by(slug: "confirmation") }

  it "approval" do
    expect(approval.allow_dissenting?).to eq true
    expect(approval.allow_dissenting).to eq true

    expect(approval.request_options.first).to eq ["approved", "Approve"]
    expect(approval.request_options.last).to eq ["declined", "Decline"]
  end

  it "confirmation" do
    expect(confirmation.allow_dissenting?).to eq false
    expect(confirmation.allow_dissenting).to eq false

    expect(confirmation.request_options.first).to eq ["approved", "Confirm"]
    expect(confirmation.request_options.count).to eq 1
  end
end
