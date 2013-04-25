class AddLinkIdToApproval < ActiveRecord::Migration
  def change
    add_column :approvals, :link_id, :string
  end
end
