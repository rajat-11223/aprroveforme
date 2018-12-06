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
          set_permission(@file_id, @user, { "type" => "anyone", "withLink" => "true" }, @role)
        end
      end
    end
  end
end
