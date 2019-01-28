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

ActiveRecord::Schema.define(version: 2019_01_24_151713) do

  create_table "archivation_requests", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id"
    t.string "title"
    t.string "message"
    t.boolean "read"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "operating_systems", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "projects", force: :cascade do |t|
    t.string "name", null: false
    t.text "description", null: false
  end

  create_table "request_templates", force: :cascade do |t|
    t.integer "cpu_cores"
    t.integer "ram_gb"
    t.integer "storage_gb"
    t.string "operating_system"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
  end

  create_table "requests", force: :cascade do |t|
    t.string "name"
    t.integer "cpu_cores"
    t.integer "ram_mb"
    t.integer "storage_mb"
    t.string "operating_system"
    t.text "comment"
    t.text "rejection_information"
    t.integer "status", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "port"
    t.string "application_name"
    t.text "description"
    t.integer "user_id"
    t.index ["user_id"], name: "index_requests_on_user_id"
  end

  create_table "responsible_users", force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "project_id", null: false
    t.index ["project_id", "user_id"], name: "index_responsible_users_on_project_id_and_user_id"
    t.index ["user_id", "project_id"], name: "index_responsible_users_on_user_id_and_project_id"
  end

  create_table "servers", force: :cascade do |t|
    t.string "name"
    t.integer "cpu_cores"
    t.integer "ram_gb"
    t.integer "storage_gb"
    t.string "mac_address"
    t.string "fqdn"
    t.string "ipv4_address"
    t.string "ipv6_address"
    t.string "installed_software", default: "--- []\n"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "model"
    t.string "vendor"
    t.string "description"
    t.integer "responsible_id"
    t.index ["responsible_id"], name: "index_servers_on_responsible_id"
  end

  create_table "slack_auth_requests", force: :cascade do |t|
    t.string "state"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_slack_auth_requests_on_user_id"
  end

  create_table "slack_hooks", force: :cascade do |t|
    t.string "url"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_slack_hooks_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "role"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "first_name"
    t.string "last_name"
    t.string "provider"
    t.string "uid"
    t.string "ssh_key"
    t.integer "user_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "users_assigned_to_requests", force: :cascade do |t|
    t.boolean "sudo"
    t.integer "request_id"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["request_id"], name: "index_users_assigned_to_requests_on_request_id"
    t.index ["user_id"], name: "index_users_assigned_to_requests_on_user_id"
  end

  create_table "virtual_machine_configs", force: :cascade do |t|
    t.string "name"
    t.string "ip"
    t.string "dns"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

end
