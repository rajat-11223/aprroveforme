class ChangeDefaultDrivePublicToTrue < ActiveRecord::Migration[5.2]
  def change
    change_column_default :approvals, :drive_public, to: true, from: false
  end
end
