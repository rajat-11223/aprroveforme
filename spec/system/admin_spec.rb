require "rails_helper"

describe "Administrator", js: true do
  before do
    sign_in_as(user)
  end

  context "as user" do
    let(:user) { create(:user, :with_subscription) }

    it "dissallows going to admin page" do
      visit(admin_root_path)

      expect(page).to_not have_current_path(admin_root_path)
    end
  end

  context "as admin" do
    let(:user) { create(:user, :with_subscription, :admin) }

    it "allows going to admin page" do
      visit(admin_root_path)

      expect(page).to have_current_path(admin_root_path)
    end
  end
end
