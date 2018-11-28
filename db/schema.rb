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

ActiveRecord::Schema.define(version: 2018_11_28_134405) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "approvals", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255
    t.string "link", limit: 255
    t.text "description"
    t.datetime "deadline"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "owner"
    t.string "embed", limit: 255
    t.string "link_title", limit: 255
    t.string "link_id", limit: 255
    t.string "link_type", limit: 255
    t.string "drive_perms", limit: 255, default: "reader"
    t.boolean "drive_public", default: true, null: false
  end

  create_table "approvers", id: :serial, force: :cascade do |t|
    t.string "email", null: false
    t.string "name", null: false
    t.string "required", default: "required", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "approval_id", null: false
    t.text "comments", default: "", null: false
    t.string "code", limit: 255
  end

  create_table "delayed_jobs", id: :serial, force: :cascade do |t|
    t.integer "priority", default: 0
    t.integer "attempts", default: 0
    t.text "handler"
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by", limit: 255
    t.string "queue", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "gdpr_customers", force: :cascade do |t|
    t.string "email", default: "t", null: false
    t.string "search", default: "t", null: false
    t.string "country", default: "t", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.integer "resource_id"
    t.string "resource_type", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
  end

  create_table "subscription_histories", id: :serial, force: :cascade do |t|
    t.datetime "plan_date"
    t.datetime "renewable_date"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "plan_name", null: false
    t.string "plan_interval", null: false
    t.string "plan_identifier", null: false
    t.string "subscription_identifier", null: false
    t.index ["user_id"], name: "index_subscription_histories_on_user_id"
  end

  create_table "subscriptions", id: :serial, force: :cascade do |t|
    t.string "plan_type", limit: 255
    t.date "plan_date"
    t.date "renewable_date"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "tasks", id: :serial, force: :cascade do |t|
    t.text "comment"
    t.string "status", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "approval_id"
    t.integer "author"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "name", limit: 255
    t.string "email", limit: 255
    t.string "provider", limit: 255
    t.string "uid", limit: 255
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "picture", limit: 255
    t.string "token", limit: 255
    t.string "first_name", limit: 255
    t.string "last_name", limit: 255
    t.string "refresh_token", limit: 255
    t.string "code", limit: 255
    t.string "second_email", limit: 255
    t.string "email_domain", limit: 255
    t.integer "approvals_sent"
    t.integer "approvals_received"
    t.integer "approvals_responded_to"
    t.integer "approvals_sent_30"
    t.integer "approvals_received_30"
    t.integer "approvals_responded_to_30"
    t.datetime "last_sent_date"
    t.string "customer_id"
    t.string "stripe_subscription_id"
    t.datetime "last_login_at"
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
  end

  add_foreign_key "subscription_histories", "users"
end
