require "rails_helper"

describe "Activation" do
  let(:user) { create(:user, :not_activated) }

  let(:mock_user) do
    OpenStruct.new uid: user.uid,
                   first_name: user.first_name,
                   last_name: user.last_name,
                   name: user.name,
                   email: user.email,
                   picture: %(https://lh4.googleusercontent.com/-Qhsxa1kvKXk/AAAAAAAAAAI/AAAAAAAACKM/mHEBI10pFqc/photo.jpg)
  end

  before { mock_omniauth_provider!(user: mock_user) }

  it "enables me to activate" do
    expect(user).to_not be_activated

    visit activate_account_url

    visit root_path
    click_link "Login"

    expect(page).to have_content("Account not activated")
    expect(page).to have_current_path(need_to_activate_account_path)

    visit activate_account_path
    expect(page).to have_content("now activated")
    expect(page).to have_current_path(dashboard_home_index_path)
  end
end
