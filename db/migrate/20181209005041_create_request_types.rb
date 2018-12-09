class CreateRequestTypes < ActiveRecord::Migration[5.2]
  def change
    create_table :request_types do |t|
      t.string :name, null: false
      t.string :affirming_text, null: false
      t.string :dissenting_text, null: false
      t.boolean :allow_dissenting, null: false, default: true
      t.string :slug, null: false
      t.boolean :public, null: false, default: false
      t.jsonb :email_templates

      t.timestamps
    end
    add_index :request_types, :slug
  end
end
