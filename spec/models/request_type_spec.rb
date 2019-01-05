# == Schema Information
#
# Table name: request_types
#
#  id               :bigint(8)        not null, primary key
#  affirming_text   :string           not null
#  allow_dissenting :boolean          default(TRUE), not null
#  dissenting_text  :string           not null
#  email_templates  :jsonb
#  name             :string           not null
#  public           :boolean          default(FALSE), not null
#  require_comments :boolean          default(TRUE), not null
#  slug             :string           not null
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
# Indexes
#
#  index_request_types_on_slug  (slug)
#

require "rails_helper"

describe RequestType do
  before { Rails.application.load_seed }
  let(:approval) { RequestType.find_by(slug: "approve") }
  let(:confirmation) { RequestType.find_by(slug: "confirm") }

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
