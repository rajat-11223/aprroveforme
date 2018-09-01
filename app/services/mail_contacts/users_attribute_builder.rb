module MailContacts
  class UsersAttributeBuilder
    def initialize(users)
      @users = users
    end

    def to_sendgrid_recipients
      @users.map do |user|
        UserAttributeBuilder.new(user).to_sendgrid_recipient_data
      end
    end
  end
end
