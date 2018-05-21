class AddLinkIdToApproval < ActiveRecord::Migration[5.0]
  def change
    add_column :approvals, :link_id, :string
  end
end
