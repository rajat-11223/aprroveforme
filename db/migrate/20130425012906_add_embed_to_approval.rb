class AddEmbedToApproval < ActiveRecord::Migration
  def change
    add_column :approvals, :embed, :string
  end
end
