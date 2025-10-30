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

ActiveRecord::Schema[8.1].define(version: 2022_02_02_191407) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "blogs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.boolean "draft", default: true
    t.boolean "pin", default: false
    t.string "slug", limit: 25
    t.text "story"
    t.text "summary"
    t.string "tag", limit: 12
    t.string "title", limit: 50
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_blogs_on_user_id"
  end

  create_table "books", force: :cascade do |t|
    t.string "author", limit: 60
    t.string "borrowers", limit: 200
    t.string "category", limit: 10
    t.integer "copies", limit: 2, default: 1
    t.datetime "created_at", null: false
    t.string "medium", limit: 10, default: "book"
    t.string "note", limit: 100
    t.string "title", limit: 100
    t.datetime "updated_at", null: false
    t.integer "year", limit: 2
  end

  create_table "dragons", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "first_name", limit: 15
    t.string "last_name", limit: 20
    t.boolean "male", default: true
    t.datetime "updated_at", null: false
  end

  create_table "games", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "difficulty", limit: 10
    t.text "pgn"
    t.string "title", limit: 64
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.index ["user_id"], name: "index_games_on_user_id"
  end

  create_table "journals", force: :cascade do |t|
    t.string "action", limit: 10
    t.datetime "created_at", precision: nil
    t.string "handle", limit: 30
    t.string "remote_ip", limit: 40
    t.string "resource", limit: 20
    t.integer "resource_id"
  end

  create_table "players", force: :cascade do |t|
    t.boolean "contact", default: false
    t.datetime "created_at", null: false
    t.string "email", limit: 50
    t.string "federation", limit: 3, default: "SCO"
    t.integer "fide_id"
    t.integer "fide_rating", limit: 2
    t.string "first_name", limit: 20
    t.string "last_name", limit: 20
    t.string "phone", limit: 20
    t.integer "rank", limit: 2
    t.string "roles", limit: 20, default: ["member"], array: true
    t.integer "sca_id"
    t.integer "sca_rating", limit: 2
    t.string "slug", limit: 40
    t.string "title", limit: 3
    t.datetime "updated_at", null: false
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "first_name", limit: 20
    t.string "handle", limit: 4
    t.string "last_name", limit: 20
    t.integer "last_otp_at"
    t.boolean "otp_required", default: false
    t.string "otp_secret", limit: 32
    t.string "password_digest"
    t.string "roles", limit: 20, default: ["member"], array: true
    t.datetime "updated_at", null: false
  end

  add_foreign_key "blogs", "users"
  add_foreign_key "games", "users"
end
