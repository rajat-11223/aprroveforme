module OmniauthHelpers

  def sign_in_as(user, provider: :google_oauth2)
    mock_omniauth_provider!(provider: provider, user: user)
    visit oauth_callback_path(provider: provider)
  end

  def self.mock_user
    OpenStruct.new uid: "123545",
                   first_name: "Mock",
                   last_name: "Bird",
                   name: "Mock Bird",
                   email: "1313@mockingbird.lane",
                   picture: %(https://lh4.googleusercontent.com/-Qhsxa1kvKXk/AAAAAAAAAAI/AAAAAAAACKM/mHEBI10pFqc/photo.jpg)
  end

  def mock_omniauth_failure!(provider: :google_oauth2)
    setup_test_mode!

    cleanup_omniauth!(provider: provider)
    cleanup_omniauth!(provider: :default)

    OmniAuth.config.mock_auth.delete(:default)
    OmniAuth.config.mock_auth[provider] = :invalid_credentials
  end

  def mock_omniauth_provider!(provider: :google_oauth2, user: nil)
    setup_test_mode!

    user ||= OmniauthHelpers.mock_user

    OmniAuth.config.mock_auth[provider] =
      OmniAuth::AuthHash.new({
        provider: provider.to_s,
        uid: user.uid,
        info: {
          first_name: user.first_name,
          last_name: user.last_name,
          name: user.name,
          email: user.email,
          image: user.picture
        }
      })
  end

  def cleanup_omniauth!(provider: :google_oauth2)
    OmniAuth.config.mock_auth[provider] = {}
  end

  private

  def setup_test_mode!
    OmniAuth.config.test_mode = true
  end

end
