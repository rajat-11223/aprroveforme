class AddDocLinkToApproval < ActiveRecord::Migration
  def change
    add_column :approvals, :link_title, :string
  end
end
