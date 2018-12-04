require "rails_helper"

describe "Allow non-google (i.e. unauthenticated) users to approve an approval", js: true do
  let(:approver) { create(:approver, :with_code) }
  let(:approval) { approver.approval }
  let(:user) { approval.user }

  context "when visiting valid response" do
    before { visit response_path(approver.id, code: approver.code) }

    it "happy path" do
      provide_comments("This is awesome!")
      click_approved

      shows_thank_you_page

      approver.reload
      expect(approver.status).to eq("approved")
      expect(approver.comments).to eq("This is awesome!")
    end
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

  context "when visiting response url with bad code" do
    let(:rand_code) { "RANDOM_CODE" }

    before { visit response_path(approver, code: rand_code) }

    it "shows thank you page" do
      shows_thank_you_page
    end
  end

  context "when visiting response url with unknown approval id" do
    let(:rand_id) { rand(50_000_000) }

    before { visit response_path(rand_id) }

    it "shows thank you page" do
      shows_thank_you_page
    end
  end

  private

  def shows_thank_you_page
    expect(page).to_not have_content(approval.title)
    expect(page).to have_content("Thank You!")
  end

  def click_approved
    accept_alert do
      find("label[for=approver_status_approved]").click
    end
  end

  def click_declined
    accept_alert do
      find("label[for=approver_status_declined]").click
    end
  end

  def provide_comments(text)
    fill_in "approver_comments", with: text
  end
end
