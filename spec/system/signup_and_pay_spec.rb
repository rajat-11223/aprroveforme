require "rails_helper"

describe "Signup and Payment", js: true do
  xit 'enables me to signup and pay' do
    visit root_path

    click_link "Sign Up Free"

    click_link "Upgrade", match: :first
    click_link "Continue"

    fill_stripe_element("4242 4242 4242 4242", "12/31", "123", "45701")

    click_button "Pay Now"
    pending "We should be paid"
  end
end
