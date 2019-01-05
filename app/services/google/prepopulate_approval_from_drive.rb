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
      approval.embed = file.embedLink
      approval.link_id = file.id
      approval.link_type = file.mimeType
      approval.link = file.alternateLink

      clear_state!
    end

    private

    attr_reader :session, :approval, :user

    def file_metadata(client, file_id)
      drive = client.discovered_api("drive", "v2")

      result = client.execute(api_method: drive.files.get,
                              parameters: {"fileId" => file_id})

      if result.status == 200
        result.data
      else
        puts "An error occurred: #{result.data["error"]["message"]}"
      end
    end

    def clear_state!
      session[:state] = {}
    end
  end
end
