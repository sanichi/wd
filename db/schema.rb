# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `rails
# db:schema:load`. When creating a new database, `rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2019_10_22_114715) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "blogs", force: :cascade do |t|
    t.boolean "draft", default: true
    t.string "title", limit: 50
    t.text "story"
    t.text "summary"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.bigint "user_id"
    t.string "tag", limit: 25
    t.boolean "pin", default: false
    t.index ["user_id"], name: "index_blogs_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", limit: 20
    t.string "last_name", limit: 20
    t.string "handle", limit: 4
    t.string "role", limit: 20, default: "member"
    t.string "password_digest"
    t.datetime "created_at", precision: 6, null: false
    t.datetime "updated_at", precision: 6, null: false
    t.string "roles", limit: 20, default: ["member"], array: true
  end

  add_foreign_key "blogs", "users"
end
