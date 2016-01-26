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

ActiveRecord::Schema.define(version: 20160122172818) do

  create_table "accounts", force: :cascade do |t|
    t.integer  "code",       limit: 4
    t.string   "name",       limit: 230
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "articles", force: :cascade do |t|
    t.string   "code",        limit: 255
    t.string   "description", limit: 255
    t.string   "status",      limit: 255
    t.integer  "material_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "articles", ["material_id"], name: "index_articles_on_material_id", using: :btree

  create_table "asset_proceedings", force: :cascade do |t|
    t.integer  "proceeding_id", limit: 4
    t.integer  "asset_id",      limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "asset_proceedings", ["asset_id"], name: "index_asset_proceedings_on_asset_id", using: :btree
  add_index "asset_proceedings", ["proceeding_id"], name: "index_asset_proceedings_on_proceeding_id", using: :btree

  create_table "assets", force: :cascade do |t|
    t.string   "code",                limit: 50
    t.text     "description",         limit: 65535
    t.integer  "auxiliary_id",        limit: 4
    t.integer  "user_id",             limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",              limit: 2
    t.integer  "account_id",          limit: 4
    t.datetime "derecognised"
    t.string   "barcode",             limit: 255
    t.integer  "state",               limit: 4
    t.text     "observation",         limit: 65535
    t.text     "description_decline", limit: 65535
    t.text     "reason_decline",      limit: 65535
    t.integer  "decline_user_id",     limit: 4
    t.string   "proceso",             limit: 255
    t.string   "observaciones",       limit: 255
    t.float    "precio",              limit: 24
  end

  add_index "assets", ["account_id"], name: "index_assets_on_account_id", using: :btree
  add_index "assets", ["auxiliary_id"], name: "index_assets_on_auxiliary_id", using: :btree
  add_index "assets", ["user_id"], name: "index_assets_on_user_id", using: :btree

  create_table "auxiliaries", force: :cascade do |t|
    t.integer  "code",       limit: 4
    t.string   "name",       limit: 230
    t.integer  "account_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",     limit: 255
  end

  add_index "auxiliaries", ["account_id"], name: "index_auxiliaries_on_account_id", using: :btree

  create_table "barcode_statuses", primary_key: "status", force: :cascade do |t|
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "barcodes", force: :cascade do |t|
    t.string   "code",       limit: 255
    t.integer  "entity_id",  limit: 4
    t.integer  "status",     limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "barcodes", ["entity_id"], name: "index_barcodes_on_entity_id", using: :btree

  create_table "buildings", force: :cascade do |t|
    t.string   "code",       limit: 50
    t.string   "name",       limit: 230
    t.integer  "entity_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",     limit: 255
  end

  add_index "buildings", ["code"], name: "index_buildings_on_code", unique: true, using: :btree
  add_index "buildings", ["entity_id"], name: "index_buildings_on_entity_id", using: :btree

  create_table "departments", force: :cascade do |t|
    t.integer  "code",        limit: 4
    t.string   "name",        limit: 230
    t.string   "status",      limit: 2
    t.integer  "building_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "departments", ["building_id"], name: "index_departments_on_building_id", using: :btree

  create_table "documentos", force: :cascade do |t|
    t.string   "titulo",     limit: 255
    t.text     "contenido",  limit: 65535
    t.string   "formato",    limit: 255
    t.string   "etiquetas",  limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "entities", force: :cascade do |t|
    t.string   "code",       limit: 50
    t.string   "name",       limit: 230
    t.string   "acronym",    limit: 50
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "header",     limit: 255
    t.string   "footer",     limit: 255
  end

  create_table "entradas_salidas", id: false, force: :cascade do |t|
    t.integer  "id",             limit: 4,                            default: 0,  null: false
    t.integer  "subarticle_id",  limit: 4
    t.date     "fecha"
    t.string   "factura",        limit: 255
    t.date     "nota_entrega"
    t.string   "nro_pedido",     limit: 11,                           default: "", null: false
    t.string   "detalle",        limit: 463
    t.integer  "cantidad",       limit: 8
    t.decimal  "costo_unitario",             precision: 10, scale: 2
    t.integer  "modelo_id",      limit: 4
    t.string   "tipo",           limit: 7,                            default: "", null: false
    t.datetime "created_at"
  end

  create_table "entry_subarticles", force: :cascade do |t|
    t.integer  "amount",        limit: 4
    t.decimal  "unit_cost",                 precision: 10, scale: 2
    t.decimal  "total_cost",                precision: 10, scale: 2
    t.string   "invoice",       limit: 255,                          default: ""
    t.date     "date"
    t.integer  "subarticle_id", limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "stock",         limit: 4,                            default: 0,     null: false
    t.integer  "note_entry_id", limit: 4
    t.boolean  "invalidate",                                         default: false
  end

  add_index "entry_subarticles", ["subarticle_id"], name: "index_entry_subarticles_on_subarticle_id", using: :btree

  create_table "kardex_prices", force: :cascade do |t|
    t.integer  "input_quantities",   limit: 4,                          default: 0,     null: false
    t.integer  "output_quantities",  limit: 4,                          default: 0,     null: false
    t.integer  "balance_quantities", limit: 4,                          default: 0,     null: false
    t.decimal  "unit_cost",                    precision: 10, scale: 2, default: 0.0,   null: false
    t.decimal  "input_amount",                 precision: 10, scale: 2, default: 0.0,   null: false
    t.decimal  "output_amount",                precision: 10, scale: 2, default: 0.0,   null: false
    t.decimal  "balance_amount",               precision: 10, scale: 2, default: 0.0,   null: false
    t.integer  "kardex_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "invalidate",                                            default: false
  end

  add_index "kardex_prices", ["kardex_id"], name: "index_kardex_prices_on_kardex_id", using: :btree

  create_table "kardexes", force: :cascade do |t|
    t.date     "kardex_date"
    t.string   "invoice_number",       limit: 255, default: "0"
    t.integer  "order_number",         limit: 4
    t.string   "detail",               limit: 255
    t.integer  "subarticle_id",        limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "delivery_note_number", limit: 255
    t.integer  "request_id",           limit: 4
    t.integer  "note_entry_id",        limit: 4
    t.boolean  "invalidate",                       default: false
  end

  add_index "kardexes", ["note_entry_id"], name: "index_kardexes_on_note_entry_id", using: :btree
  add_index "kardexes", ["request_id"], name: "index_kardexes_on_request_id", using: :btree
  add_index "kardexes", ["subarticle_id"], name: "index_kardexes_on_subarticle_id", using: :btree

  create_table "materials", force: :cascade do |t|
    t.string   "code",        limit: 50
    t.string   "description", limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",      limit: 2
  end

  create_table "note_entries", force: :cascade do |t|
    t.integer  "delivery_note_number", limit: 4
    t.date     "delivery_note_date"
    t.string   "invoice_number",       limit: 255,                          default: ""
    t.date     "invoice_date"
    t.integer  "supplier_id",          limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.decimal  "total",                            precision: 10, scale: 2
    t.integer  "user_id",              limit: 4
    t.date     "note_entry_date"
    t.boolean  "invalidate",                                                default: false
    t.string   "message",              limit: 255
    t.string   "invoice_autorizacion", limit: 255
    t.string   "c31",                  limit: 255
  end

  add_index "note_entries", ["supplier_id"], name: "index_note_entries_on_supplier_id", using: :btree

  create_table "proceedings", force: :cascade do |t|
    t.integer  "user_id",         limit: 4
    t.integer  "admin_id",        limit: 4
    t.string   "proceeding_type", limit: 2
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "proceedings", ["admin_id"], name: "index_proceedings_on_admin_id", using: :btree
  add_index "proceedings", ["user_id"], name: "index_proceedings_on_user_id", using: :btree

  create_table "requests", force: :cascade do |t|
    t.integer  "admin_id",      limit: 4
    t.integer  "user_id",       limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "status",        limit: 255, default: "0"
    t.datetime "delivery_date"
    t.boolean  "invalidate",                default: false
    t.string   "message",       limit: 255
  end

  create_table "subarticle_requests", force: :cascade do |t|
    t.integer "subarticle_id",    limit: 4
    t.integer "request_id",       limit: 4
    t.integer "amount",           limit: 4
    t.integer "amount_delivered", limit: 4
    t.integer "total_delivered",  limit: 4, default: 0
    t.boolean "invalidate",                 default: false
  end

  add_index "subarticle_requests", ["request_id"], name: "index_subarticle_requests_on_request_id", using: :btree
  add_index "subarticle_requests", ["subarticle_id"], name: "index_subarticle_requests_on_subarticle_id", using: :btree

  create_table "subarticles", force: :cascade do |t|
    t.string   "code",        limit: 255
    t.string   "description", limit: 255
    t.string   "unit",        limit: 255
    t.string   "status",      limit: 255
    t.integer  "article_id",  limit: 4
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "amount",      limit: 4
    t.integer  "minimum",     limit: 4
    t.string   "barcode",     limit: 255
  end

  add_index "subarticles", ["article_id"], name: "index_subarticles_on_article_id", using: :btree

  create_table "suppliers", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nit",        limit: 255
    t.string   "telefono",   limit: 255
    t.string   "contacto",   limit: 255
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",    null: false
    t.string   "encrypted_password",     limit: 255, default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,   default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "username",               limit: 230, default: "",    null: false
    t.integer  "code",                   limit: 4
    t.string   "name",                   limit: 230
    t.string   "title",                  limit: 230
    t.integer  "ci",                     limit: 4
    t.string   "phone",                  limit: 230
    t.string   "mobile",                 limit: 230
    t.string   "status",                 limit: 2
    t.integer  "department_id",          limit: 4
    t.string   "role",                   limit: 255
    t.boolean  "password_change",                    default: false, null: false
    t.integer  "assets_count",           limit: 4,   default: 0
  end

  add_index "users", ["email"], name: "index_users_on_email", using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["username"], name: "index_users_on_username", using: :btree

  create_table "versions", force: :cascade do |t|
    t.string   "item_type",    limit: 255,                  null: false
    t.integer  "item_id",      limit: 4
    t.string   "event",        limit: 255,                  null: false
    t.string   "whodunnit",    limit: 255
    t.text     "object",       limit: 65535
    t.datetime "created_at"
    t.boolean  "active",                     default: true
    t.string   "item_spanish", limit: 255
  end

  add_index "versions", ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id", using: :btree

end
