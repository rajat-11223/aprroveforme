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

  before { mock_omniauth_provider!(user: mock_user) }

  it "enables me to signup" do
    visit root_path
    click_link "Sign Up"
    expect(page).to have_current_path(need_to_activate_account_path)

    user = User.find_by(uid: 123545)

    expect(user).to be_present
    expect(user.name).to eq "Mock Bird"
    expect(user.email).to eq "1313@mockingbird.lane"
    expect(user.first_name).to eq "Mock"
    expect(user.last_name).to eq "Bird"
    expect(user.picture).to include("googleusercontent")

    expect(user).to_not be_activated

    # Sends email with with activation_link
    expect(ActionMailer::Base.deliveries.count).to eq(1)
    mail = ActionMailer::Base.deliveries.last
    expect(mail).to be_present
    expect(mail.to).to include("1313@mockingbird.lane")
    expect(mail.subject).to include("Welcome")
    expect(mail.body.encoded).to include(activate_account_url)
  end

  context "when user doesn't have an image" do
    before do
      mock_user.picture = nil
      mock_omniauth_provider!(user: mock_user)
    end

    it "enables me to sign up and sets picture to gravatar" do
      visit root_path
      click_link "Sign Up"
      expect(page).to have_current_path(need_to_activate_account_path)

      user = User.find_by(uid: 123545)
      expect(user.picture).to include("gravatar")
      expect(user.last_login_at).to_not be_nil
    end
  end

  context "when credentials fail" do
    before do
      mock_omniauth_failure!
    end

    it "redirects to home page and shows me an error" do
      visit root_path
      click_link "Sign Up"
      expect(page).to have_current_path(root_path)
      expect(page).to have_content("Authentication error: invalid_credentials")
    end
  end

  context "when invalid provider" do
    before do
      cleanup_omniauth!
    end

    it "redirects to home page and shows me an error" do
      visit root_path
      click_link "Sign Up"
      expect(page).to have_current_path(root_path)
      expect(page).to have_content("We don't support that provider")
    end
  end
end
