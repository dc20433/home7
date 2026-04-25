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

ActiveRecord::Schema[8.1].define(version: 2026_04_25_141835) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.bigint "record_id", null: false
    t.string "record_type", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.string "content_type"
    t.datetime "created_at", null: false
    t.string "filename", null: false
    t.string "key", null: false
    t.text "metadata"
    t.string "service_name", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "charts", force: :cascade do |t|
    t.text "assess"
    t.datetime "created_at", precision: 0, null: false
    t.string "name"
    t.string "o_treats"
    t.text "obj"
    t.text "plan"
    t.bigint "regi_id", null: false
    t.text "subj"
    t.date "t_date"
    t.datetime "updated_at", precision: 0, null: false
    t.index ["regi_id"], name: "index_charts_on_regi_id"
  end

  create_table "filings", force: :cascade do |t|
    t.datetime "created_at", precision: 0, null: false
    t.text "describe"
    t.bigint "regi_id", null: false
    t.datetime "updated_at", precision: 0, null: false
    t.index ["regi_id"], name: "index_filings_on_regi_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "alcohol"
    t.string "aq_b4"
    t.string "aq_where"
    t.string "aqrist"
    t.string "better"
    t.string "c_onset"
    t.string "cell"
    t.string "city"
    t.string "com1"
    t.string "com2"
    t.string "com3"
    t.string "company"
    t.datetime "created_at", precision: 0, null: false
    t.decimal "d_lost", precision: 4, scale: 1
    t.date "d_onset"
    t.decimal "d_restd", precision: 4, scale: 1
    t.string "di_list", default: [], array: true
    t.string "diag_given"
    t.string "diag_where"
    t.string "email"
    t.date "h_when"
    t.decimal "height", precision: 2, scale: 1
    t.string "home"
    t.string "hosp"
    t.string "inj_surg"
    t.date "last_prd"
    t.string "m_stat"
    t.string "med_taken"
    t.string "name"
    t.string "o_dis"
    t.string "o_drs"
    t.date "o_drs_when"
    t.string "occup"
    t.string "pain_scale"
    t.boolean "patient_consent", default: false
    t.string "pcp_name"
    t.string "preg"
    t.integer "preg_wks"
    t.string "referred"
    t.bigint "regi_id", null: false
    t.text "signature"
    t.string "signed_as"
    t.datetime "signed_at"
    t.string "state"
    t.string "street"
    t.string "string", default: [], array: true
    t.string "tobacco"
    t.datetime "updated_at", precision: 0, null: false
    t.date "v_date"
    t.decimal "weight", precision: 4, scale: 1
    t.string "work"
    t.string "worse"
    t.string "zip"
    t.index ["regi_id"], name: "index_patients_on_regi_id"
  end

  create_table "regis", force: :cascade do |t|
    t.datetime "created_at", precision: 0, null: false
    t.date "dob"
    t.string "first_name"
    t.string "gender"
    t.string "init"
    t.string "last_name"
    t.datetime "updated_at", precision: 0, null: false
  end

  create_table "sessions", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "data"
    t.string "ip_address"
    t.string "session_id"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.bigint "user_id", null: false
    t.index ["session_id"], name: "index_sessions_on_session_id", unique: true
    t.index ["updated_at"], name: "index_sessions_on_updated_at"
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.boolean "admin"
    t.datetime "created_at", precision: 0, null: false
    t.datetime "current_sign_in_at", precision: 0
    t.string "current_sign_in_ip"
    t.string "email", default: "", null: false
    t.boolean "is_active", default: true
    t.datetime "last_sign_in_at", precision: 0
    t.string "last_sign_in_ip"
    t.datetime "last_sign_out_at"
    t.string "password_digest", default: "", null: false
    t.datetime "remember_created_at", precision: 0
    t.datetime "reset_password_sent_at", precision: 0
    t.string "reset_password_token"
    t.integer "role", default: 0
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "updated_at", precision: 0, null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "charts", "regis"
  add_foreign_key "filings", "regis"
  add_foreign_key "patients", "regis"
  add_foreign_key "sessions", "users"
end
