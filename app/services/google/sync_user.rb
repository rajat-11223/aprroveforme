module Google
  class SyncUser
    def initialize(user)
      @user = user
    end

    def call(auth)
      info = auth["info"]
      return unless info.present?

      user.update_attributes! first_name: info["first_name"] || "",
                              last_name: info["last_name"] || "",
                              token: auth.dig("credentials", "token"),
                              refresh_token: auth.dig("credentials", "refresh_token") || user.refresh_token,
                              expires: auth.dig("credentials", "expires"),
                              expires_at: Time.at(auth.dig("credentials", "expires_at")),
                              name: info["name"] || "",
                              email: info["email"] || "",
                              picture: info["image"] || GravatarUrl.generate(info["email"])
    end

    private

    attr_reader :user
  end
end
