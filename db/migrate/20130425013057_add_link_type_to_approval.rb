class AddLinkTypeToApproval < ActiveRecord::Migration[5.0]
  def change
    add_column :approvals, :link_type, :string
  end
end
