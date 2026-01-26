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

ActiveRecord::Schema[7.1].define(version: 2024_01_26_150001) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "daily_stats", force: :cascade do |t|
    t.bigint "hospital_id", null: false
    t.date "date", null: false
    t.integer "min_wait"
    t.integer "max_wait"
    t.float "avg_wait"
    t.integer "sample_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["date"], name: "index_daily_stats_on_date"
    t.index ["hospital_id", "date"], name: "index_daily_stats_on_hospital_id_and_date", unique: true
    t.index ["hospital_id"], name: "index_daily_stats_on_hospital_id"
  end

  create_table "hospitals", force: :cascade do |t|
    t.text "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "hourly_stats", force: :cascade do |t|
    t.bigint "hospital_id", null: false
    t.datetime "hour", null: false
    t.integer "min_wait"
    t.integer "max_wait"
    t.float "avg_wait"
    t.integer "sample_count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hospital_id", "hour"], name: "index_hourly_stats_on_hospital_id_and_hour", unique: true
    t.index ["hospital_id"], name: "index_hourly_stats_on_hospital_id"
    t.index ["hour"], name: "index_hourly_stats_on_hour"
  end

  create_table "wait_times", force: :cascade do |t|
    t.integer "value"
    t.bigint "hospital_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["hospital_id"], name: "index_wait_times_on_hospital_id"
  end

  add_foreign_key "daily_stats", "hospitals"
  add_foreign_key "hourly_stats", "hospitals"
  add_foreign_key "wait_times", "hospitals"
end
