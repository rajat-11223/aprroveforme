module Google
  class SyncUser
    def initialize(user)
      @user = user
    end

    def call(auth_hash)
      info = auth_hash['info']
      return unless info.present?

      user.update_attributes! first_name: info['first_name'] || "",
                              last_name: info['last_name'] || "",
                              name: info['name'] || "",
                              email: info['email'] || "",
                              picture: info['image'] || GravatarUrl.generate(info['email'])
    end

    private

    attr_reader :user
  end
end
