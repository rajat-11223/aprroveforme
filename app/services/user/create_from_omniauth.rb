class User
  class CreateFromOmniauth
    def initialize(auth)
      @auth = auth
    end

    def call
      User.create! do |user|
        user.provider = auth['provider']
        user.uid = auth['uid']
        info = auth['info']

        if info.present?
          user.assign_attributes first_name: info['first_name'] || "",
                                 last_name: info['last_name'] || "",
                                 name: info['name'] || "",
                                 email: info['email'] || "",
                                 picture: info['image'] || GravatarUrl.generate(info['email'])
        end
      end.tap do |user|
        UserMailer.new_user(user.name, user.email).deliver_later
      end
    end

    private

    attr_reader :auth
  end
end
