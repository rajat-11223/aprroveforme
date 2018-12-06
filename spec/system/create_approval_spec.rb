require "rails_helper"

describe "Create Approval", js: true do
  let(:user) { create(:user, :with_subscription) }

  before do
    sign_in_as(user)
  end

  it 'signup and navigate to account' do
    within(".top-bar") do
      click_link "Home"
    end

    click_link "New Approval"

    set_hidden_value(id: "approval_link", value: "https://www.google.com")
    set_hidden_value(id: "approval_embed", value: "https://www.google.com")
    set_hidden_value(id: "approval_link_title", value: "Super Fun Document")
    # We don't want to set link_id since we're not ACTUALLY logged in
    # and this will trigger google permission setting
    # set_hidden_value(id: "approval_link_id", value: "1MYcLkPpQQ8HiTzAsuq0ZbBg5Enq_mCOpPbuse90MgPU")
    set_hidden_value(id: "approval_link_type", value: "document")

    fill_in "Title", with: "Fun Document"
    fill_in "Description", with: "Joy comes from reading this"
    fill_in "datepicker", with: 5.days.from_now.strftime("%m/%d/%Y")

    expect(page.all(".approver").size).to eq(3)
    within page.all(".approver").first do
      fill_in "approval_approvers_attributes_0_name", with: "Ricky Chilcott"
      fill_in "approval_approvers_attributes_0_email", with: "ricky@rickychilcott.com"
      select "Required", from: "approval_approvers_attributes_0_required"
    end

    # Make sure you can add a another approver
    click_button "Add Another Approver"
    expect(page.all(".approver").size).to eq(4)

    click_button "Submit Approval"

    expect(page).to have_selector(:css, "body.approvals.show")

    approval = Approval.last
    expect(page).to have_current_path(approval_path(approval))
    expect(approval.title).to eq("Fun Document")
    expect(approval.description).to eq("Joy comes from reading this")
    expect(approval.link).to eq("https://www.google.com")
    expect(approval.approvers.count).to eq(1)

    expect(Approval.count).to eq(1)
  end

  def set_hidden_value(id:, value: )
    find(%(##{id}), visible: false)
    page.execute_script(%(document.getElementById("#{id}").value = "#{value}"))
  end
end
