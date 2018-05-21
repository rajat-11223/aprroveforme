class AddCommentsToApprover < ActiveRecord::Migration[5.0]
  def change
    add_column :approvers, :comments, :text
  end
end
