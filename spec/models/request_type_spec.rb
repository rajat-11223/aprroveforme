require "rails_helper"

describe RequestType do
  it ".available_options" do
    expect(RequestType.available_options.length).to eq(2)

    RequestType.available_options.each do |option|
      expect(option).to be_a RequestType
    end
  end

  it "approval" do
    approval = RequestType.approval

    expect(approval.allow_dissenting?).to eq true
    expect(approval.allow_dissenting).to eq true

    expect(approval.request_options.first).to eq ["approved", "Approve"]
    expect(approval.request_options.last).to eq ["declined", "Decline"]
  end

  it "confirmation" do
    confirmation = RequestType.confirmation

    expect(confirmation.allow_dissenting?).to eq false
    expect(confirmation.allow_dissenting).to eq false

    expect(confirmation.request_options.first).to eq ["approved", "Confirm"]
    expect(confirmation.request_options.count).to eq 1
  end
end
