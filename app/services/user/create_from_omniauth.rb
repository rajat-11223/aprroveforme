class User
  class CreateFromOmniauth
    def initialize(auth)
      @auth = auth
    end

    def call
      User.create! do |user|
        user.provider = auth["provider"]
        user.uid = auth["uid"]
        info = auth["info"]

        if info.present?
          user.assign_attributes first_name: info["first_name"] || "",
                                 last_name: info["last_name"] || "",
                                 token: auth.dig("credentials", "token"),
                                 refresh_token: auth.dig("credentials", "refresh_token"),
                                 expires: auth.dig("credentials", "expires"),
                                 expires_at: Time.at(auth.dig("credentials", "expires_at")),
                                 name: info["name"] || "",
                                 email: info["email"] || "",
                                 picture: info["image"] || GravatarUrl.generate(info["email"])
        end
      end.tap do |user|
        WelcomeMailer.new_user(user: user).deliver_later
      end
    end

    private

    attr_reader :auth
  end
end
