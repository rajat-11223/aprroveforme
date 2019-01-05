require "google/apis/drive_v3"

module Google
  module Drive
    module File
      module SetPermission
        # class InvalidGoogleUser < StandardError; end
        # class DoNotOwnDocument < StandardError; end
        # class UnknownError < StandardError; end

        private

        def set_permission(file_id, user, permission, role = "reader", retry_count = 0)
          if file_id.blank?
            Rails.logger.info "File ID not present... moving along #{user.inspect}; #{permission.inspect}"
            return
          end

          user.refresh_google_auth!

          drive = Google::Apis::DriveV3::DriveService.new
          drive.authorization = user.google_auth.to_authorization

          permission.role = role

          begin
            drive.create_permission(file_id, permission, send_notification_email: false)
            # rescue "invalidSharingRequest" => e
            #   raise InvalidGoogleUser, "You tried to add #{permission_config["value"]}. Since there is no Google account associated with this email address, we have made this document readable by non-Google users."
            # rescue "forbidden" => e
            #   raise DoNotOwnDocument, "You tried to share a file that you do not own. Please ask the owner to make you the owner or share another document."
          rescue => e
            Rails.logger.info("SET PERMISSION ERROR: #{e.inspect}")
          end
        end
      end
    end
  end
end
