# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_01_29_152920) do
  create_table "credentials", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "external_id", null: false
    t.string "public_key", null: false
    t.integer "sign_count", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["external_id"], name: "index_credentials_on_external_id", unique: true
    t.index ["user_id"], name: "index_credentials_on_user_id", unique: true
  end

  create_table "profiles", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "name", null: false
    t.string "email", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_profiles_on_email", unique: true
    t.index ["name"], name: "index_profiles_on_name", unique: true
    t.index ["user_id"], name: "index_profiles_on_user_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "webauthn_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["webauthn_id"], name: "index_users_on_webauthn_id", unique: true
  end

  add_foreign_key "credentials", "users"
  add_foreign_key "profiles", "users"
end
