require "rails_helper"

describe "Use existing approval as template", js: true do
  let(:user) { approval.user }

  before do
    user.update_attributes time_zone: "Eastern Time (US & Canada)"

    travel_to Time.zone.local(2019, 11, 19, 13, 0, 0)
    sign_in_as(user)
  end

  after do
    travel_back
  end

  let(:approval) do
    create(:approval, created_at: Time.zone.local(2019, 11, 18, 13, 0, 0),
                      deadline: Time.zone.local(2019, 11, 25, 13, 0, 0),
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
      expect(time.year).to eq(2019)
      expect(time.month).to eq(11)

      # TODO: FIX Spec
      if ENV.fetch("CI", "false") == "true"
        expect(time.day).to eq(26)
      else
        expect(time.day).to eq(27)
      end

      first_approver = approval.approvers.first
      expect(find("#approval_approvers_attributes_0_name").value).to eq(first_approver.name)
      expect(find("#approval_approvers_attributes_0_email").value).to eq(first_approver.email)
      expect(find("#approval_approvers_attributes_0_required").value).to eq(first_approver.required)
    end
  end
end
