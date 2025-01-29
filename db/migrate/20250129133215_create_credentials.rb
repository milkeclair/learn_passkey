class CreateCredentials < ActiveRecord::Migration[8.0]
  def change
    create_table :credentials do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :external_id, null: false, index: { unique: true }
      t.string :public_key, null: false
      t.integer :sign_count, null: false, default: 0

      t.timestamps
    end
  end
end
