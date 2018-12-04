require "rails_helper"

describe "Edit Approval", js: true do
  let(:approval) { create(:approval, user: user) }
  let(:user) { create(:user, :with_subscription) }

  before do
    sign_in_as(user)
  end

  it "signup and navigate to account" do
    visit edit_approval_path(approval)

    fill_in "Title", with: "Newest of Titles"
    fill_in "Description", with: "Joy comes from reading this"
    fill_in "datepicker", with: 5.days.from_now.strftime("%m/%d/%Y")

    expect(page.all(".approver").size).to eq(1)

    click_button "Update Approval"

    expect(page).to have_selector(:css, "body.approvals.show")

    approval = Approval.last
    expect(page).to have_current_path(approval_path(approval))
    expect(approval.title).to eq("Newest of Titles")
    expect(approval.description).to eq("Joy comes from reading this")
    expect(approval.approvers.count).to eq(1)

    expect(Approver.count).to eq(1)
  end
end
