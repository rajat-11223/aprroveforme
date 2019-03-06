class TickleNewUsers
  def call
    EMAIL_TEMPLATES_TO_USERS.each do |(template, to_users)|
      users = to_users.call

      Rails.logger.info("Sending #{template} to #{users.count}")
      users.each do |user|
        Rails.logger.info(WelcomeMailer.send(template, user: user).message) #.deliver_later
      end
    end
  end

  USERS_WITHOUT_APPROVALS = User.where(approvals_sent: 0).or(User.where(approvals_sent: nil))

  EMAIL_TEMPLATES_TO_USERS = {
    day_one: -> { USERS_WITHOUT_APPROVALS.where("created_at > ?", 2.days.ago).where("created_at < ?", 1.days.ago) },
    day_three: -> { USERS_WITHOUT_APPROVALS.where("created_at > ?", 4.days.ago).where("created_at < ?", 3.days.ago) },
    day_seven: -> { USERS_WITHOUT_APPROVALS.where("created_at > ?", 8.days.ago).where("created_at < ?", 7.days.ago) },
  }
end
