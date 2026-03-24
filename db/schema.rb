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

ActiveRecord::Schema[8.1].define(version: 2026_03_24_134912) do
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
    t.datetime "created_at", null: false
    t.text "obj"
    t.text "plan"
    t.bigint "regi_id", null: false
    t.text "subj"
    t.string "t_date"
    t.datetime "updated_at", null: false
    t.index ["regi_id"], name: "index_charts_on_regi_id"
  end

  create_table "filings", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.text "describe"
    t.date "f_date"
    t.string "image"
    t.bigint "regi_id", null: false
    t.datetime "updated_at", null: false
    t.index ["regi_id"], name: "index_filings_on_regi_id"
  end

  create_table "patients", force: :cascade do |t|
    t.string "aq_b4"
    t.string "cell"
    t.string "city"
    t.string "comp1"
    t.string "comp2"
    t.string "comp3"
    t.string "company"
    t.datetime "created_at", null: false
    t.string "d_onset"
    t.string "di_list"
    t.string "diag_given"
    t.string "email"
    t.string "height"
    t.string "home"
    t.string "last_prd"
    t.string "m_stat"
    t.string "name"
    t.string "o_dis"
    t.string "occup"
    t.string "pain_scale"
    t.string "preg"
    t.string "preg_wks"
    t.string "referred"
    t.bigint "regi_id", null: false
    t.string "state"
    t.string "street"
    t.datetime "updated_at", null: false
    t.date "v_date"
    t.string "weight"
    t.string "work"
    t.string "zip"
    t.index ["regi_id"], name: "index_patients_on_regi_id"
  end

  create_table "regis", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "dob"
    t.string "first_name"
    t.string "gender"
    t.string "init"
    t.string "last_name"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "charts", "regis"
  add_foreign_key "filings", "regis"
  add_foreign_key "patients", "regis"
end
