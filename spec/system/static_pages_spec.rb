require "rails_helper"

describe "Navigate to static pages" do
  it 'home' do
    visit_page_with_content(path: root_path, content: "ApproveForMe")
  end

  it "how it works" do
    visit_page_with_content(path: page_path("how-it-works"), content: "How It Works")
  end

  it "pricing" do
    visit_page_with_content(path: page_path("pricing"), content: "Pricing")
  end

  it "about" do
    visit_page_with_content(path: page_path("about"), content: "About")
  end

  it "faq" do
    visit_page_with_content(path: page_path("faq"), content: "Frequently Asked Questions")
  end

  it "terms" do
    visit_page_with_content(path: page_path("terms"), content: "Terms of Service")
  end

  it "priacy" do
    visit_page_with_content(path: page_path("privacy"), content: "Privacy Policy")
  end
end

def visit_page_with_content(path:, content:)
  visit path
  expect(page).to have_current_path(path)
  expect(page).to have_content(content)
end
