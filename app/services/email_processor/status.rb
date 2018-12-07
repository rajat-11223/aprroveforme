class EmailProcessor
  class Status < Base
    triggered_by :status

    def process
      Rails.logger.info "We're processing a Status message"

      u = User.find_by(email: from_email)
      EmailFlow::StatusMailer.update(u).deliver_later
    end
  end
end
