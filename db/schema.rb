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

ActiveRecord::Schema.define(version: 2019_01_02_172410) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "active_admin_comments", force: :cascade do |t|
    t.string "namespace"
    t.text "body"
    t.string "resource_type"
    t.bigint "resource_id"
    t.string "author_type"
    t.bigint "author_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["author_type", "author_id"], name: "index_active_admin_comments_on_author_type_and_author_id"
    t.index ["namespace"], name: "index_active_admin_comments_on_namespace"
    t.index ["resource_type", "resource_id"], name: "index_active_admin_comments_on_resource_type_and_resource_id"
  end

  create_table "approvals", id: :serial, force: :cascade do |t|
    t.string "title", limit: 255, null: false
    t.string "link", limit: 255
    t.text "description", default: "", null: false
    t.datetime "deadline", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "owner", null: false
    t.string "embed", limit: 255
    t.string "link_title", limit: 255
    t.string "link_id", limit: 255
    t.string "link_type", limit: 255
    t.string "drive_perms", limit: 255, default: "reader"
    t.boolean "drive_public", default: true, null: false
    t.datetime "completed_at"
    t.bigint "request_type_id"
    t.index ["completed_at"], name: "index_approvals_on_completed_at"
    t.index ["request_type_id"], name: "index_approvals_on_request_type_id"
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
    t.datetime "responded_at"
  end

  create_table "gdpr_customers", force: :cascade do |t|
    t.string "email", default: "t", null: false
    t.string "search", default: "t", null: false
    t.string "country", default: "t", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "request_types", force: :cascade do |t|
    t.string "name", null: false
    t.string "affirming_text", null: false
    t.string "dissenting_text", null: false
    t.boolean "allow_dissenting", default: true, null: false
    t.string "slug", null: false
    t.boolean "public", default: false, null: false
    t.jsonb "email_templates"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "require_comments", default: true, null: false
    t.index ["slug"], name: "index_request_types_on_slug"
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
    t.string "time_zone"
    t.datetime "expires_at"
    t.boolean "expires"
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
  end

  add_foreign_key "approvals", "request_types"
  add_foreign_key "subscription_histories", "users"
end
