# encoding: UTF-8
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
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20140416070532) do

  create_table "approvals", :force => true do |t|
    t.string   "title"
    t.string   "link"
    t.text     "description"
    t.datetime "deadline"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "owner"
    t.string   "embed"
    t.string   "link_title"
    t.string   "link_id"
    t.string   "link_type"
    t.string   "perms"
  end

  create_table "approvers", :force => true do |t|
    t.string   "email"
    t.string   "name"
    t.string   "required"
    t.string   "status"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "approval_id"
    t.text     "comments"
    t.string   "code"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.text     "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.string   "queue"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
  end

  add_index "delayed_jobs", ["priority", "run_at"], :name => "delayed_jobs_priority"

  create_table "roles", :force => true do |t|
    t.string   "name"
    t.integer  "resource_id"
    t.string   "resource_type"
    t.datetime "created_at",    :null => false
    t.datetime "updated_at",    :null => false
  end

  add_index "roles", ["name", "resource_type", "resource_id"], :name => "index_roles_on_name_and_resource_type_and_resource_id"
  add_index "roles", ["name"], :name => "index_roles_on_name"

  create_table "subscriptions", :force => true do |t|
    t.string   "plan_type"
    t.date     "plan_date"
    t.date     "renewable_date"
    t.integer  "user_id"
    t.datetime "created_at",     :null => false
    t.datetime "updated_at",     :null => false
  end

  create_table "tasks", :force => true do |t|
    t.text     "comment"
    t.string   "status"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
    t.integer  "approval_id"
    t.integer  "author"
  end

  create_table "users", :force => true do |t|
    t.string   "name"
    t.string   "email"
    t.string   "provider"
    t.string   "uid"
    t.datetime "created_at",                :null => false
    t.datetime "updated_at",                :null => false
    t.string   "picture"
    t.string   "token"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "refresh_token"
    t.string   "code"
    t.string   "second_email"
    t.string   "email_domain"
    t.integer  "approvals_sent"
    t.integer  "approvals_received"
    t.integer  "approvals_responded_to"
    t.integer  "approvals_sent_30"
    t.integer  "approvals_received_30"
    t.integer  "approvals_responded_to_30"
    t.datetime "last_sent_date"
  end

  create_table "users_roles", :id => false, :force => true do |t|
    t.integer "user_id"
    t.integer "role_id"
  end

  add_index "users_roles", ["user_id", "role_id"], :name => "index_users_roles_on_user_id_and_role_id"

end
