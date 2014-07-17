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

ActiveRecord::Schema.define(version: 20140714193648) do

  create_table "accounts", force: true do |t|
    t.integer  "code"
    t.string   "name",       limit: 230
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "articles", force: true do |t|
    t.string   "code"
    t.string   "description"
    t.string   "status"
    t.integer  "material_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "articles", ["material_id"], name: "index_articles_on_material_id", using: :btree

  create_table "asset_proceedings", force: true do |t|
    t.integer  "proceeding_id"
    t.integer  "asset_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "asset_proceedings", ["asset_id"], name: "index_asset_proceedings_on_asset_id", using: :btree
  add_index "asset_proceedings", ["proceeding_id"], name: "index_asset_proceedings_on_proceeding_id", using: :btree

  create_table "assets", force: true do |t|
    t.string   "code",         limit: 50
    t.text     "description"
    t.integer  "auxiliary_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",       limit: 2
    t.integer  "account_id"
    t.datetime "derecognised"
  end

  add_index "assets", ["account_id"], name: "index_assets_on_account_id", using: :btree
  add_index "assets", ["auxiliary_id"], name: "index_assets_on_auxiliary_id", using: :btree
  add_index "assets", ["user_id"], name: "index_assets_on_user_id", using: :btree

  create_table "auxiliaries", force: true do |t|
    t.integer  "code"
    t.string   "name",       limit: 230
    t.integer  "account_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
  end

  add_index "auxiliaries", ["account_id"], name: "index_auxiliaries_on_account_id", using: :btree

  create_table "buildings", force: true do |t|
    t.string   "code",       limit: 50
    t.string   "name",       limit: 230
    t.integer  "entity_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status"
  end

  add_index "buildings", ["code"], name: "index_buildings_on_code", unique: true, using: :btree
  add_index "buildings", ["entity_id"], name: "index_buildings_on_entity_id", using: :btree

  create_table "declines", force: true do |t|
    t.string   "asset_code"
    t.string   "account_code"
    t.string   "auxiliary_code"
    t.string   "department_code"
    t.string   "user_code"
    t.string   "description"
    t.string   "reason"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "declines", ["user_id"], name: "index_declines_on_user_id", using: :btree

  create_table "departments", force: true do |t|
    t.integer  "code"
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
    t.string   "header"
    t.string   "footer"
  end

  create_table "materials", force: true do |t|
    t.string   "code",        limit: 50
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",      limit: 2
  end

  create_table "proceedings", force: true do |t|
    t.integer  "user_id"
    t.integer  "admin_id"
    t.string   "proceeding_type", limit: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "proceedings", ["admin_id"], name: "index_proceedings_on_admin_id", using: :btree
  add_index "proceedings", ["user_id"], name: "index_proceedings_on_user_id", using: :btree

  create_table "requests", force: true do |t|
    t.integer  "admin_id"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",        default: "0"
    t.datetime "delivery_date"
  end

  create_table "subarticle_requests", force: true do |t|
    t.integer "subarticle_id"
    t.integer "request_id"
    t.integer "amount"
    t.integer "amount_delivered"
    t.integer "total_delivered",  default: 0
  end

  add_index "subarticle_requests", ["request_id"], name: "index_subarticle_requests_on_request_id", using: :btree
  add_index "subarticle_requests", ["subarticle_id"], name: "index_subarticle_requests_on_subarticle_id", using: :btree

  create_table "subarticles", force: true do |t|
    t.string   "code"
    t.string   "description"
    t.string   "unit"
    t.string   "status"
    t.integer  "article_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount"
    t.integer  "minimum"
    t.string   "barcode"
  end

  add_index "subarticles", ["article_id"], name: "index_subarticles_on_article_id", using: :btree

  create_table "users", force: true do |t|
    t.string   "email",                              default: "",    null: false
    t.string   "encrypted_password",                 default: "",    null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",               limit: 230, default: "",    null: false
    t.integer  "code"
    t.string   "name",                   limit: 230
    t.string   "title",                  limit: 230
    t.integer  "ci"
    t.string   "phone",                  limit: 230
    t.string   "mobile",                 limit: 230
    t.string   "status",                 limit: 2
    t.integer  "department_id"
    t.string   "role"
    t.boolean  "password_change",                    default: false, null: false
    t.integer  "assets_count",                       default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  create_table "versions", force: true do |t|
    t.string   "item_type",                 null: false
    t.integer  "item_id"
    t.string   "event",                     null: false
    t.string   "whodunnit"
    t.text     "object"
    t.datetime "created_at"
    t.boolean  "active",     default: true
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
