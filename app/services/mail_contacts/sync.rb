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
         print '.'

         Rails.logger.info "Sendgrid Response"
         Rails.logger.info response.status_code
         Rails.logger.info response.body
         Rails.logger.info response.headers
      end
    end

    private

    attr_reader :users, :batch_size, :sendgrid_client
  end
end
