require "rails_helper"

describe "Account Nav", js: true do
  it "signup and navigate to account" do
    visit root_path
    click_link "Sign Up Free"

    hover_top_nav_account_image
    within("nav#main") do
      click_link "Account"
    end

    expect(page).to have_current_path(need_to_activate_account_path)
    user = User.last
    user.update_attributes activated_at: Time.now

    visit profile_account_path
    expect(page).to have_content("Mock")
    expect(page).to have_content("Bird")
    expect(page).to have_content("1313@mockingbird.lane")

    expect(page).to have_current_path(profile_account_path)
  end

  def hover_top_nav_account_image
    within("nav#main") do
      find("#account-dropdown").hover
    end
  end
end
