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
          set_permission(@file_id, @user, { "type" => "user", "value" => @approver.email }, @role)
        end
      end
    end
  end
end
