class User < ActiveRecord::Base
  rolify
  attr_accessible :role_ids, :as => :admin
  attr_accessible :provider, :uid, :name, :email

  def self.create_with_omniauth(auth)
    create! do |user|
      user.provider = auth['provider']
      user.uid = auth['uid']
      if auth['info']
         user.name = auth['info']['name'] || ""
         user.email = auth['info']['email'] || ""
      end
      UserMailer.delay.new_user(user.name, user.email)
    end
  end

end
