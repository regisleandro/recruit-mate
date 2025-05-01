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

ActiveRecord::Schema[7.1].define(version: 2025_05_01_175532) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "candidates", force: :cascade do |t|
    t.string "name", null: false
    t.string "curriculum"
    t.text "curriculum_summary"
    t.string "cellphone_number"
    t.string "cpf"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cpf"], name: "index_candidates_on_cpf", unique: true
    t.index ["name"], name: "index_candidates_on_name"
    t.index ["user_id"], name: "index_candidates_on_user_id"
  end

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_companies_on_user_id"
  end

  create_table "job_applications", force: :cascade do |t|
    t.bigint "candidate_id", null: false
    t.bigint "job_id", null: false
    t.integer "status", default: 0
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["candidate_id", "job_id"], name: "index_job_applications_on_candidate_id_and_job_id", unique: true
    t.index ["candidate_id"], name: "index_job_applications_on_candidate_id"
    t.index ["job_id"], name: "index_job_applications_on_job_id"
    t.index ["status"], name: "index_job_applications_on_status"
    t.index ["user_id"], name: "index_job_applications_on_user_id"
  end

  create_table "jobs", force: :cascade do |t|
    t.text "description"
    t.bigint "company_id", null: false
    t.text "benefits"
    t.string "keywords"
    t.datetime "start_time"
    t.datetime "end_time"
    t.integer "interval_time"
    t.integer "status", default: 0
    t.text "prompt"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "title"
    t.bigint "user_id", null: false
    t.index ["company_id"], name: "index_jobs_on_company_id"
    t.index ["keywords"], name: "index_jobs_on_keywords"
    t.index ["status"], name: "index_jobs_on_status"
    t.index ["user_id"], name: "index_jobs_on_user_id"
  end

  create_table "recruiters", force: :cascade do |t|
    t.string "name"
    t.text "prompt"
    t.string "telegram_token"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.string "openai_key"
    t.index ["user_id"], name: "index_recruiters_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.string "jti"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.index ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["jti"], name: "index_users_on_jti"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "whats_app_business_configs", force: :cascade do |t|
    t.string "access_token"
    t.string "phone_number_id"
    t.string "business_account_id"
    t.bigint "recruiter_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "verify_token"
    t.bigint "user_id", null: false
    t.index ["recruiter_id"], name: "index_whats_app_business_configs_on_recruiter_id"
    t.index ["user_id"], name: "index_whats_app_business_configs_on_user_id"
  end

  add_foreign_key "candidates", "users"
  add_foreign_key "companies", "users"
  add_foreign_key "job_applications", "candidates"
  add_foreign_key "job_applications", "jobs"
  add_foreign_key "job_applications", "users"
  add_foreign_key "jobs", "companies"
  add_foreign_key "jobs", "users"
  add_foreign_key "recruiters", "users"
  add_foreign_key "whats_app_business_configs", "recruiters"
  add_foreign_key "whats_app_business_configs", "users"
end
