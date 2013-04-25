class AddLinkTypeToApproval < ActiveRecord::Migration
  def change
    add_column :approvals, :link_type, :string
  end
end
