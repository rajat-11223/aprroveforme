module MailContacts
  class UserAttributeBuilder
    def initialize(user)
      @user = user
    end

    def to_sendgrid_recipient_data
      user.
        attributes.
        slice(*stock_attributes).
        merge({
        "signed_up_date" => user.created_at,
        "created_first_approval" => (approvals_count > 0).to_s,
        "created_first_approval_date" => approvals.first.try(:created_at),
        "completed_one_approval" => completed_approvals.any?.to_s,
        "entered_credit_card" => payment_sources.any?.to_s,
        "active_plan_type" => subscription.try(:plan_name),
        "active_plan_interval" => subscription.try(:plan_interval),
      }).
        compact # remove empty values
    end

    private

    attr_reader :user

    def stock_attributes
      # attributes we already have and are named correctly
      [
        "email",
        "first_name",
        "last_name",
        "approvals_sent",
        "approvals_received",
        "approvals_responded_to",
        "approvals_sent_30",
        "approvals_received_30",
        "approvals_responded_to_30",
        "last_sent_date",
      ]
    end

    def payment_sources
      @payment_sources ||= user.payment_customer.try(:sources).try(:to_a) || []
    end

    def approvals
      @approvals ||= user.approvals
    end

    def approvals_count
      @approvals_count ||= approvals.count
    end

    def completed_approvals
      approvals.complete
    end

    def subscription
      @subscription ||= user.subscription
    end
  end
end
