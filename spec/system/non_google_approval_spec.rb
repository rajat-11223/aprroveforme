require "rails_helper"

describe "Allow non-google (i.e. unauthenticated) users to approve an approval", js: true do
  let(:approver) { create(:approver, :with_code) }
  let(:approval) { approver.approval }
  let(:user) { approval.user }

  after do
    travel_back
  end

  context "when visiting old url" do
    before do
      visit("approvals/#{approval.id}&?code=#{approver.code}")
    end

    it "redirects from old url to new url properly" do
      expect(page).to have_current_path(response_path(approver, code: approver.code))
      expect(page).to have_content(approval.title)
    end
  end
end
