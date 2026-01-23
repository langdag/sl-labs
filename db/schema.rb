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

ActiveRecord::Schema[8.1].define(version: 2026_01_23_132938) do
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

  create_table "activities", force: :cascade do |t|
    t.string "action_type", null: false
    t.string "before_sha"
    t.integer "commit_count", default: 0
    t.datetime "created_at", null: false
    t.string "head_sha"
    t.datetime "occurred_at", null: false
    t.string "ref"
    t.bigint "repository_id", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["action_type"], name: "index_activities_on_action_type"
    t.index ["occurred_at"], name: "index_activities_on_occurred_at"
    t.index ["repository_id"], name: "index_activities_on_repository_id"
    t.index ["user_id"], name: "index_activities_on_user_id"
  end

  create_table "commits", force: :cascade do |t|
    t.string "author_email", null: false
    t.string "author_name"
    t.datetime "committed_at", null: false
    t.datetime "created_at", null: false
    t.text "message"
    t.jsonb "parent_shas", default: []
    t.bigint "repository_id", null: false
    t.string "sha", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["author_email"], name: "index_commits_on_author_email"
    t.index ["committed_at"], name: "index_commits_on_committed_at"
    t.index ["repository_id", "sha"], name: "index_commits_on_repository_id_and_sha", unique: true
    t.index ["repository_id"], name: "index_commits_on_repository_id"
    t.index ["sha"], name: "index_commits_on_sha"
    t.index ["user_id"], name: "index_commits_on_user_id"
  end

  create_table "repositories", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name"
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_repositories_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.text "bio"
    t.string "company"
    t.datetime "created_at", null: false
    t.string "email_address", null: false
    t.string "full_name"
    t.string "location"
    t.string "password_digest", null: false
    t.string "status"
    t.string "twitter_handle"
    t.datetime "updated_at", null: false
    t.string "username"
    t.string "website"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "activities", "repositories"
  add_foreign_key "activities", "users"
  add_foreign_key "commits", "repositories"
  add_foreign_key "commits", "users"
  add_foreign_key "repositories", "users"
end
