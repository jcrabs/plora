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

ActiveRecord::Schema[7.1].define(version: 2024_08_27_124118) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "annotations", force: :cascade do |t|
    t.float "lat"
    t.float "lon"
    t.string "name"
    t.text "description"
    t.bigint "map_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["map_id"], name: "index_annotations_on_map_id"
  end

  create_table "explored_points_of_interest", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "point_of_interest_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["point_of_interest_id"], name: "index_explored_points_of_interest_on_point_of_interest_id"
    t.index ["user_id"], name: "index_explored_points_of_interest_on_user_id"
  end

  create_table "maps", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_maps_on_user_id"
  end

  create_table "points", force: :cascade do |t|
    t.float "lat"
    t.float "lon"
    t.bigint "segment_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["segment_id"], name: "index_points_on_segment_id"
  end

  create_table "points_of_interest", force: :cascade do |t|
    t.string "name"
    t.string "category"
    t.text "description"
    t.float "lat"
    t.float "lon"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_points_of_interest_on_user_id"
  end

  create_table "segments", force: :cascade do |t|
    t.bigint "map_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["map_id"], name: "index_segments_on_map_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "home_address"
    t.float "home_lat"
    t.float "home_lon"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "annotations", "maps"
  add_foreign_key "explored_points_of_interest", "points_of_interest", column: "point_of_interest_id"
  add_foreign_key "explored_points_of_interest", "users"
  add_foreign_key "maps", "users"
  add_foreign_key "points", "segments"
  add_foreign_key "points_of_interest", "users"
  add_foreign_key "segments", "maps"
end
