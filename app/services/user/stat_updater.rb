class User
  class StatUpdater
    def initialize(user)
      @user = user
    end

    def call
      user.update_attributes({
        email_domain: user.email.split("@").try(:last),
        approvals_sent: approvals.count,
        approvals_received: approvals_received.count,
        approvals_responded_to: approvals_received.approved_or_declined.count,
        approvals_sent_30: approvals.from_this_month.count,
        approvals_received_30: approvals_received.from_this_month.count,
        approvals_responded_to_30: approvals_received.approved_or_declined.from_this_month.count,
        last_sent_date: approvals.last.try(:created_at)
      })
    end

    private

    attr_reader :user

    def approvals
      @approvals ||= user.approvals
    end

    def approvals_received
      @approvals_received ||= Approver.by_user(user)
    end
  end
end
