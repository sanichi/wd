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

ActiveRecord::Schema[8.1].define(version: 2026_10_15_131855) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "blogs", force: :cascade do |t|
    t.boolean "draft", default: true
    t.string "title", limit: 50, null: false
    t.text "story"
    t.text "summary", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.boolean "pin", default: false
    t.string "slug", limit: 25
    t.string "tag", limit: 12
    t.index ["slug"], name: "index_blogs_on_slug", unique: true
    t.index ["user_id"], name: "index_blogs_on_user_id"
  end

  create_table "books", force: :cascade do |t|
    t.string "author", limit: 60, null: false
    t.string "borrowers", limit: 200
    t.string "category", limit: 10
    t.integer "copies", limit: 2, default: 1
    t.string "medium", limit: 10, default: "book"
    t.string "note", limit: 100
    t.string "title", limit: 100, null: false
    t.integer "year", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author", "title"], name: "index_books_on_author_and_title", unique: true
  end

  create_table "dragons", force: :cascade do |t|
    t.string "first_name", limit: 15, null: false
    t.string "last_name", limit: 20, null: false
    t.boolean "male", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["last_name", "first_name"], name: "index_dragons_on_last_name_and_first_name", unique: true
  end

  create_table "games", force: :cascade do |t|
    t.text "pgn", null: false
    t.string "title", limit: 64, null: false
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "difficulty", limit: 10
    t.index ["user_id"], name: "index_games_on_user_id"
  end

  create_table "journals", force: :cascade do |t|
    t.string "action", limit: 10
    t.datetime "created_at", precision: nil, null: false
    t.string "handle", limit: 30
    t.integer "resource_id"
    t.string "remote_ip", limit: 40
    t.string "resource", limit: 20
    t.index ["resource_id"], name: "index_journals_on_resource_id"
  end

  create_table "lms_fixtures", force: :cascade do |t|
    t.integer "season_id", null: false
    t.integer "event_id", null: false
    t.string "event_name", limit: 12, null: false
    t.integer "fixture_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["fixture_id"], name: "index_lms_fixtures_on_fixture_id", unique: true
    t.index ["season_id", "event_id"], name: "index_lms_fixtures_on_season_id_and_event_id"
  end

  create_table "players", force: :cascade do |t|
    t.boolean "contact", default: false
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
    t.string "title", limit: 3
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "slug", limit: 40
    t.index ["email"], name: "index_players_on_email", unique: true
    t.index ["fide_id"], name: "index_players_on_fide_id", unique: true
    t.index ["last_name", "first_name"], name: "index_players_on_last_name_and_first_name", unique: true
    t.index ["sca_id"], name: "index_players_on_sca_id", unique: true
  end

  create_table "users", force: :cascade do |t|
    t.string "first_name", limit: 20
    t.string "last_name", limit: 20
    t.string "handle", limit: 4
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "roles", limit: 20, default: ["member"], array: true
    t.boolean "otp_required", default: false
    t.string "otp_secret", limit: 32
    t.integer "last_otp_at"
    t.index ["handle"], name: "index_users_on_handle", unique: true
  end

  add_foreign_key "blogs", "users"
  add_foreign_key "games", "users"
end
