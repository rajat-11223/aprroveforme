class CreateGdprCustomers < ActiveRecord::Migration[5.2]
  def change
    create_table :gdpr_customers do |t|
      t.string :email, null: false, default: true
      t.string :search, null: false, default: true
      t.string :country, null: false, default: true

      t.timestamps
    end
  end
end
