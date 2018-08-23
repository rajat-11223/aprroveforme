require "rails_helper"

describe "Signup" do
  let(:mock_user) do
    OpenStruct.new uid: "123545",
                   first_name: "Mock",
                   last_name: "Bird",
                   name: "Mock Bird",
                   email: "1313@mockingbird.lane",
                   picture: %(https://lh4.googleusercontent.com/-Qhsxa1kvKXk/AAAAAAAAAAI/AAAAAAAACKM/mHEBI10pFqc/photo.jpg)
  end

  before do
    mock_omniauth_provider!(user: mock_user)
  end

  it 'enables me to signup' do
    visit root_path
    click_link "Login or Signup"
    expect(page).to have_current_path(pricing_path)

    user = User.find_by(uid: 123545)

    expect(user).to be_present
    expect(user.name).to eq "Mock Bird"
    expect(user.email).to eq "1313@mockingbird.lane"
    expect(user.first_name).to eq "Mock"
    expect(user.last_name).to eq "Bird"
    expect(user.picture).to include("googleusercontent")
  end

  context "when user doesn't have an image" do
    before do
      mock_user.picture = nil
      mock_omniauth_provider!(user: mock_user)
    end

    it 'enables me to sign up and sets picture to gravatar' do
      visit root_path
      click_link "Login or Signup"
      expect(page).to have_current_path(pricing_path)

      user = User.find_by(uid: 123545)
      expect(user.picture).to include('gravatar')
    end
  end

  context "when credentials fail" do
    before do
      mock_omniauth_failure!
    end

    it 'redirects to home page and shows me an error' do
      visit root_path
      click_link "Login or Signup"
      expect(page).to have_current_path(root_path)
      expect(page).to have_content("Authentication error: invalid_credentials")
    end
  end

  context "when invalid provider" do
    before do
      cleanup_omniauth!
    end

    it 'redirects to home page and shows me an error' do
      visit root_path
      click_link "Login or Signup"
      expect(page).to have_current_path(root_path)
      expect(page).to have_content("We don't support that provider")
    end
  end
end
