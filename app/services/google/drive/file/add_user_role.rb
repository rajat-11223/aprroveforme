module Google
  module Drive
    module File
      class AddUserRole
        include SetPermission

        def initialize(file_id, user:, approver:, role:)
          @file_id = file_id
          @user = user
          @approver = approver
          @role = role
        end

        def call
          set_permission(@file_id, @user, user_permission, @role)
        end

        private

        def user_permission
          Google::Apis::DriveV3::Permission.new(type: "user", email_address: @approver.email)
        end
      end
    end
  end
end
