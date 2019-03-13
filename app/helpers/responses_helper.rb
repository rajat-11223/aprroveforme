module ResponsesHelper
  def approval_action_text(approval)
    case approval.drive_perms.to_sym
    when :writer
      "edit"
    when :commenter
      "comment"
    else
      "view"
    end
  end
end
