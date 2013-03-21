class AddCommentsToApprover < ActiveRecord::Migration
  def change
    add_column :approvers, :comments, :text
  end
end
