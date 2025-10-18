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

ActiveRecord::Schema[8.0].define(version: 2025_10_18_002008) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "hotspot_users", force: :cascade do |t|
    t.bigint "router_id", null: false
    t.string "username", null: false
    t.string "password", null: false
    t.string "profile", default: "default"
    t.string "limit_uptime"
    t.string "limit_bytes_in"
    t.string "limit_bytes_out"
    t.string "limit_bytes_total"
    t.boolean "disabled", default: false
    t.boolean "created_via_api", default: false
    t.datetime "expires_at"
    t.datetime "first_login_at"
    t.datetime "last_login_at"
    t.bigint "total_bytes_in", default: 0
    t.bigint "total_bytes_out", default: 0
    t.string "mac_address"
    t.string "comment"
    t.decimal "price_paid", precision: 8, scale: 2
    t.string "payment_reference"
    t.string "created_by"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["created_at"], name: "index_hotspot_users_on_created_at"
    t.index ["expires_at"], name: "index_hotspot_users_on_expires_at"
    t.index ["payment_reference"], name: "index_hotspot_users_on_payment_reference"
    t.index ["router_id", "disabled"], name: "index_hotspot_users_on_router_id_and_disabled"
    t.index ["router_id", "username"], name: "index_hotspot_users_on_router_id_and_username", unique: true
    t.index ["router_id"], name: "index_hotspot_users_on_router_id"
    t.index ["username"], name: "index_hotspot_users_on_username"
  end

  create_table "ip_history_logs", force: :cascade do |t|
    t.bigint "router_id", null: false
    t.string "ip_address", null: false
    t.datetime "detected_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["router_id"], name: "index_ip_history_logs_on_router_id"
  end

  create_table "routers", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.string "location"
    t.string "ddns_hostname", null: false
    t.string "current_ip"
    t.string "api_username", null: false
    t.string "api_password", null: false
    t.integer "api_port", default: 8728
    t.boolean "ddns_enabled", default: true
    t.datetime "last_seen_at"
    t.string "router_identity"
    t.string "ros_version"
    t.boolean "active", default: true
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ddns_hostname"], name: "index_routers_on_ddns_hostname", unique: true
    t.index ["user_id", "active"], name: "index_routers_on_user_id_and_active"
    t.index ["user_id"], name: "index_routers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "hotspot_users", "routers"
  add_foreign_key "ip_history_logs", "routers"
  add_foreign_key "routers", "users"
end
