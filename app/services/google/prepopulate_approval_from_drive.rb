require "google/apis"
require "google/apis/drive_v2"

module Google
  class PrepopulateApprovalFromDrive
    def initialize(session, approval, user)
      @session = session
      @approval = approval
      @user = user
    end

    def call
      state = session[:state]

      return unless state && state["action"] == "open"

      # Pull out ids of Google Drive files
      # exportIds => Google Doc Files
      # ids => Images or other uploaded files
      file_id = state.dig("exportIds", 0) || state.dig("ids", 0)
      file = file_metadata(file_id)

      return if file.blank?

      approval.title = file.title
      approval.link_title = file.title
      approval.embed = file.embed_link
      approval.link_id = file.id
      approval.link_type = file.mime_type
      approval.link = file.alternate_link

      clear_state!
    end

    private

    attr_reader :session, :approval, :user

    def file_metadata(file_id)
      return if file_id.blank?

      user.refresh_google_auth!(force: true)

      drive = Google::Apis::DriveV2::DriveService.new
      drive.authorization = user.google_auth.to_authorization

      drive.get_file(file_id)
    rescue Google::Apis::ClientError => e
      # @raise [] The request is invalid and should not be retried without modification
      # It's possible that the user selecteed a different user account for the file,
      # just return nil
      Rails.logger.info("CLIENT ERROR for google e.inspect")
      nil
    rescue Google::Apis::ServerError, Google::Apis::AuthorizationError => e
      nil
    end

    def clear_state!
      session[:state] = {}
    end
  end
end
