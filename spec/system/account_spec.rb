require "rails_helper"

describe "Account Nav", js: true do
  it 'signup and navigate to account' do
    visit root_path
    click_link "Sign Up Free"

    hover_top_nav_account_image
    within(".top-bar") do
      click_link "Account"
    end

    expect(page).to have_content("Mock")
    expect(page).to have_content("Bird")
    expect(page).to have_content("1313@mockingbird.lane")

    expect(page).to have_current_path(profile_account_path)
  end

  def hover_top_nav_account_image
    within(".top-bar") do
      find("#account-dropdown").hover
    end
  end
end
