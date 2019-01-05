module Google
  module Drive
    module File
      class MakePublic
        include SetPermission

        def initialize(file_id, user:, role:)
          @file_id = file_id
          @user = user
          @role = role
        end

        def call
          set_permission(@file_id, @user, public_permission, @role)
        end

        private

        def public_permission
          Google::Apis::DriveV3::Permission.new(allow_file_discovery: false, type: "anyone")
        end
      end
    end
  end
end
