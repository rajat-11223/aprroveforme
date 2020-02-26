require "rails_helper"

describe "Navigate to static page" do
  it 'home' do
    visit_page_with_content(visit_path: root_path, content: "ApproveForMe")
  end

  it "how it works" do
    visit_page_with_content(visit_path: page_path("how-it-works"), content: "How It Works")
  end

  it "pricing" do
    visit_page_with_content(visit_path: page_path("pricing"), content: "Pricing")
  end

  it "about" do
    visit_page_with_content(visit_path: page_path("about"), content: "About")
  end

  it "faq" do
    visit_page_with_content(visit_path: page_path("faq"), content: "Frequently Asked Questions")
  end

  it "terms" do
    visit_page_with_content(visit_path: page_path("terms"), content: "Terms of Service")
  end

  it "privacy" do
    visit_page_with_content(visit_path: page_path("privacy"), content: "Privacy Policy")
  end

  context "when signed in visiting" do
    let(:user) { create(:user) }

    before do
      mock_omniauth_provider!(user: user)
      visit root_path
      click_link "Login"
    end

    it 'home' do
      visit signin_path
      visit_page_with_content(visit_path: root_path, result_path: dashboard_home_index_path, content: "ApproveForMe")
    end

    it "how it works" do
      visit_page_with_content(visit_path: page_path("how-it-works"), content: "How It Works")
    end

    it "pricing" do
      visit_page_with_content(visit_path: page_path("pricing"), content: "Pricing")
    end

    it "about" do
      visit_page_with_content(visit_path: page_path("about"), content: "About")
    end

    it "faq" do
      visit_page_with_content(visit_path: page_path("faq"), content: "Frequently Asked Questions")
    end

    it "terms" do
      visit_page_with_content(visit_path: page_path("terms"), content: "Terms of Service")
    end

    it "privacy" do
      visit_page_with_content(visit_path: page_path("privacy"), content: "Privacy Policy")
    end
  end
end

def visit_page_with_content(visit_path:, content:, result_path: nil)
  visit visit_path
  expect(page).to have_current_path(result_path || visit_path)
  expect(page).to have_content(content)
end
