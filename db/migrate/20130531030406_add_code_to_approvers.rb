class AddCodeToApprovers < ActiveRecord::Migration[5.0]
  def change
    add_column :approvers, :code, :string
  end
end
