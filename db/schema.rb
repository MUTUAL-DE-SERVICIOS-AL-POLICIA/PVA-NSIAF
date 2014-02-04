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
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140204190653) do

  create_table "accounts", force: true do |t|
    t.string   "code",       limit: 50
    t.string   "name",       limit: 230
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "auxiliaries", force: true do |t|
    t.string   "code",       limit: 50
    t.string   "name",       limit: 230
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "auxiliaries", ["account_id"], name: "index_auxiliaries_on_account_id", using: :btree

  create_table "buildings", force: true do |t|
    t.string   "code",       limit: 50
    t.string   "name",       limit: 230
    t.integer  "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "buildings", ["code"], name: "index_buildings_on_code", unique: true, using: :btree
  add_index "buildings", ["entity_id"], name: "index_buildings_on_entity_id", using: :btree

  create_table "departments", force: true do |t|
    t.string   "code",        limit: 50
    t.string   "name",        limit: 230
    t.string   "status",      limit: 2
    t.integer  "building_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "departments", ["building_id"], name: "index_departments_on_building_id", using: :btree

  create_table "entities", force: true do |t|
    t.string   "code",       limit: 50
    t.string   "name",       limit: 230
    t.string   "acronym",    limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", force: true do |t|
    t.string   "email",                              default: "", null: false
    t.string   "encrypted_password",                 default: "", null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,  null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",               limit: 230, default: "", null: false
    t.string   "code",                   limit: 230
    t.string   "name",                   limit: 230
    t.string   "title",                  limit: 230
    t.integer  "ci"
    t.string   "phone",                  limit: 230
    t.string   "mobile",                 limit: 230
    t.string   "status",                 limit: 1
    t.integer  "department_id"
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

end
