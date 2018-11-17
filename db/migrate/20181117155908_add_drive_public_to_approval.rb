class AddDrivePublicToApproval < ActiveRecord::Migration[5.2]
  def change
    add_column :approvals, :drive_public, :boolean, default: false, null: false

    rename_column :approvals, :perms, :drive_perms
    Approval.where(drive_perms: nil).update_all(drive_perms: "reader")
    change_column_default :approvals, :drive_perms, to: "reader", from: nil
    change_column_null :approvals, :drive_perms, true
  end
end
