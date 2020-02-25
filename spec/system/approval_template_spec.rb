require "rails_helper"

describe "Use existing approval as template", js: true do
  let(:user) { approval.user }
  let(:this_year) { Time.now.year }
  let(:next_year) { this_year + 1 }

  before do
    user.update_attributes time_zone: "Eastern Time (US & Canada)"
    sign_in_as(user)
  end

  let!(:approval) do
    create(:approval, created_at: Time.zone.local(this_year, 11, 18, 13, 0, 0),
                      deadline: Time.zone.local(next_year, 11, 18, 13, 0, 0),
                      drive_perms: "writer",
                      drive_public: true)
  end

  it "new approval has old information" do
    within("#sidebar") do
      click_link "Open Approvals"
    end

    within("#approval_#{approval.id}") do
      click_link "Use As Template"
    end

    within("form") do
      expect(find("#approval_drive_perms").checked?).to eq(true)
      expect(find("#approval_drive_perms").value).to eq("writer")
      expect(find("#approval_drive_public").checked?).to eq(false)

      time_str = find("#datepicker", visible: false).value
      time = Time.parse(time_str)
      expect(time.year).to eq(next_year)
      expect(time.month).to eq(Time.now.month)
      expect(time.day).to eq(Time.now.day)

      first_approver = approval.approvers.first
      expect(find("#approval_approvers_attributes_0_name").value).to eq(first_approver.name)
      expect(find("#approval_approvers_attributes_0_email").value).to eq(first_approver.email)
      expect(find("#approval_approvers_attributes_0_required").value).to eq(first_approver.required)
    end
  end
end
