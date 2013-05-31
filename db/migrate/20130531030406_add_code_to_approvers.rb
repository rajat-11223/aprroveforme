class AddCodeToApprovers < ActiveRecord::Migration
  def change
    add_column :approvers, :code, :string
  end
end
