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

ActiveRecord::Schema[7.0].define(version: 2023_08_25_132922) do
  create_table "events", charset: "utf8mb4", force: :cascade do |t|
    t.integer "amount"
    t.integer "category"
    t.string "date"
    t.string "store_name"
    t.integer "group_id"
    t.boolean "is_private", default: false
    t.string "create_user"
    t.string "update_user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", charset: "utf8mb4", force: :cascade do |t|
    t.string "manage_user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb4", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest", null: false
    t.integer "group_id", null: false
    t.string "name"
    t.integer "register_type"
    t.string "refresh_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
