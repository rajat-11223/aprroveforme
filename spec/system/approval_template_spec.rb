require "rails_helper"

describe "Use existing approval as template", js: true do
  let(:approval) { create(:approval, created_at: 1.day.ago.beginning_of_day, deadline: 6.days.from_now.end_of_day, drive_perms: "writer", drive_public: true ) }
  let(:user) { approval.user }

  before do
    sign_in_as(user)
  end

  it 'new approval has old information' do
    within("#sidebar") do
      click_link "Open Approvals"
    end

    within("#approval_#{approval.id}") do
      click_link "Use As Template"
    end

    within("form") do
      expect(find("#approval_drive_perms").value).to eq("writer")
      expect(find("#approval_drive_public").value).to eq("true")
      expect(find("#datepicker").value).to eq(7.days.from_now.beginning_of_day.strftime("%m/%d/%Y"))
      expect(find("#datepicker").value).to eq(7.days.from_now.beginning_of_day.strftime("%m/%d/%Y"))

      first_approver = approval.approvers.first
      expect(find("#approval_approvers_attributes_0_name").value).to eq(first_approver.name)
      expect(find("#approval_approvers_attributes_0_email").value).to eq(first_approver.email)
      expect(find("#approval_approvers_attributes_0_required").value).to eq(first_approver.required)
    end
  end
end
