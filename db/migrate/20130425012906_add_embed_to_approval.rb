class AddEmbedToApproval < ActiveRecord::Migration[5.0]
  def change
    add_column :approvals, :embed, :string
  end
end
