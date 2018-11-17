module Google
  module Drive
    module File
      module SetPermission
        class InvalidGoogleUser < StandardError; end

        private

        def set_permission(file_id, user, permission_options, role="reader", retry_count=0)
          user.refresh_google
          client = user.google_auth
          drive = client.discovered_api("drive", "v2")

          permission_config = { "role" => role }.merge(permission_options)

          new_permission = drive.permissions.insert.request_schema.new(permission_config)

          result = client.execute(api_method: drive.permissions.insert,
                                  body_object: new_permission,
                                  parameters: { "fileId" => file_id, "sendNotificationEmails"=>"false" })

          case result.status
          when 200
            result.data
          when 401 # token has expired
            if retry_count > 3
              Rails.logger.error "[Error] Timed Out after #{retry_count} attempts"
              Rails.logger.error "[Error] occurred when setting permissions: #{result.data["error"]["message"]}"
              return
            end

            user.refresh_google
            set_permissions(file_id, user, permission_options, role, retry_count+1)
          else
            process_result_error(result, permission_config)
          end
        end

        def process_result_error(result, permission_config={})
          error = result.data["error"] || {}
          reason = error.dig("errors", 0, "reason")
          message = error["message"]

          case reason
          when "invalidSharingRequest"
            raise InvalidGoogleUser, "You tried to add #{permission_config["value"]}. Since there is no Google account associated with this email address, we have made this document readable by non-Google users."
          else
            raise reason, message
          end

          Rails.logger.error "[Error] occurred when setting permissions: #{message}"
        end
      end
    end
  end
end
