class AddProfile < ActiveRecord::Migration[8.0]
  def change
    create_table :profiles do |t|
      t.references :user, null: false, foreign_key: true, index: { unique: true }
      t.string :name, null: false, index: { unique: true }
      t.string :email, null: false, index: { unique: true }
      t.timestamps
    end
  end
end
