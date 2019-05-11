# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20190511131431) do

  create_table "cabs", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cust_id"
    t.boolean "is_pink"
    t.boolean "is_available"
    t.integer "lat"
    t.integer "long"
  end

  create_table "customers", force: :cascade do |t|
    t.string "cab_id"
    t.boolean "pink_preference"
    t.integer "src_lat"
    t.integer "src_long"
    t.integer "dest_lat"
    t.integer "dest_long"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "rides", force: :cascade do |t|
    t.integer "fare"
    t.integer "cab_id"
    t.integer "customer_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "ride_start_time"
    t.datetime "ride_end_time"
    t.integer "dist_travelled"
    t.boolean "pink_pref"
    t.index ["cab_id"], name: "index_rides_on_cab_id"
    t.index ["customer_id"], name: "index_rides_on_customer_id"
  end

end
