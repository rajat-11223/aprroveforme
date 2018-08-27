require "rails_helper"

describe "Logout", js: true do
  let(:user) { create(:user, :with_subscription) }

  before do
    sign_in_as(user)
  end

  it 'signup and navigate to account' do
    hover_top_nav_account_image
    within(".top-bar") do
      click_link "Log out"
    end

    expect(page).to have_current_path(root_path)
  end

  def hover_top_nav_account_image
    within(".top-bar") do
      find("#account-dropdown").hover
    end
  end
end
