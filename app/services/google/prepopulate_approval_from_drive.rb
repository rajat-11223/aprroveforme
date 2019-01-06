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
      file_ids = state["exportIds"] || state["ids"]
      file_id = file_ids.first

      return unless file_id.present?

      user.refresh_google_auth!
      api_client = user.google_auth

      file = file_metadata(api_client, file_id)

      return unless file.present?

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

    def file_metadata(client, file_id)
      user.refresh_google_auth!

      drive = Google::Apis::DriveV2::DriveService.new
      drive.authorization = user.google_auth.to_authorization

      drive.get_file(file_id)
      # if result.status == 200
      #   result.data
      # else
      #   puts "An error occurred: #{result.data["error"]["message"]}"
      # end
    end

    def clear_state!
      session[:state] = {}
    end
  end
end
