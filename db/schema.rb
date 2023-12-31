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

ActiveRecord::Schema[7.0].define(version: 2023_10_28_053042) do
  create_table "events", charset: "utf8mb4", force: :cascade do |t|
    t.integer "amount", null: false
    t.integer "category"
    t.string "date"
    t.string "store_name"
    t.string "memo"
    t.integer "group_id", null: false
    t.string "create_user"
    t.string "update_user"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "groups", charset: "utf8mb4", force: :cascade do |t|
    t.string "manage_user"
    t.integer "revision", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patterns", charset: "utf8mb4", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "store_name", null: false
    t.integer "category", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "privates", charset: "utf8mb4", force: :cascade do |t|
    t.integer "amount", null: false
    t.integer "category"
    t.string "date"
    t.string "store_name"
    t.string "memo"
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "users", charset: "utf8mb4", force: :cascade do |t|
    t.string "email", null: false
    t.string "password_digest"
    t.integer "group_id", null: false
    t.string "name"
    t.integer "register_type"
    t.integer "auth_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
  end

end
