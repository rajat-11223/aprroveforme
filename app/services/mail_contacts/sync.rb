module MailContacts
  class Sync
    def self.all!
      new(User.includes(:approvals), batch_size: 1000).sync!
    end

    def initialize(users, sendgrid_client: nil, batch_size: nil)
      @users = users
      @batch_size = batch_size || 1000
      @sendgrid_client = sendgrid_client || SendGrid::API.new(api_key: ENV.fetch("SENDGRID_API_KEY")).client
    end

    def sync!
      users.find_in_batches(batch_size: batch_size) do |group|
        Rails.logger.info "Building attrs for all users"
        sg_recipient_data = UsersAttributeBuilder.new(group).to_sendgrid_recipients

        Rails.logger.info "Updating/creating contacts for all users"
        response = sendgrid_client.
                     contactdb.
                     recipients.
                     patch(request_body: sg_recipient_data)

         Rails.logger.info "Sendgrid Response"
         Rails.logger.info response.status_code
         Rails.logger.info response.body
         Rails.logger.info response.headers
      end
    end

    private

    attr_reader :users, :batch_size, :sendgrid_client
  end

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

  class UserAttributeBuilder
    def initialize(user)
      @user = user
    end

    def to_sendgrid_recipient_data
      user.
        attributes.
        slice("email", "first_name", "last_name"). # attributes we already have and are named correctly
        merge({
          "signed_up_at" => user.created_at,
          "created_first_approval" => (approvals_count > 0).to_s,
          "created_first_approval_at" => approvals.first.try(:created_at),
          "approval_count" => approvals_count,
          "completed_one_approval" => completed_approvals.any?.to_s,
          "entered_credit_card" => payment_sources.any?.to_s,
          "active_plan_type" => subscription.try(:plan_name),
          "active_plan_interval" => subscription.try(:plan_interval),
        }).
        compact # remove empty values
    end

    private

    attr_reader :user

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
      approvals.map(&:complete?)
    end

    def subscription
      @subscription ||= user.subscription
    end
  end
end
