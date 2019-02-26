require "rails_helper"

describe "Signup and Payment", js: true, ci_ignore: true do
  it "enables me to signup and pay" do
    visit root_path

    click_link "Sign Up"

    user =
      loop do
        user = User.last
        break(user) if user.present?
      end

    user.update_attributes activated_at: Time.now

    click_link "Change Plan", match: :first
    click_link "Upgrade", match: :first
    click_link "Continue"

    fill_stripe_element("4242 4242 4242 4242", "12/31", "123", "45701")

    click_button "Pay Now"

    expect(page).to have_content("Upgraded to professional, billed monthly")

    user.reload
    expect(user).to be_paid
    expect(user.subscription).to be_professional
    expect(user.subscription).to be_monthly
  end
end
