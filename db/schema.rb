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

ActiveRecord::Schema[8.0].define(version: 2025_03_27_000000) do
  create_table "habit_logs", force: :cascade do |t|
    t.integer "habit_id", null: false
    t.integer "user_id", null: false
    t.date "date", null: false
    t.boolean "completed", default: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["habit_id", "date"], name: "index_habit_logs_on_habit_id_and_date", unique: true
    t.index ["habit_id"], name: "index_habit_logs_on_habit_id"
    t.index ["user_id"], name: "index_habit_logs_on_user_id"
  end

  create_table "habits", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.string "frequency"
    t.boolean "active", default: true
    t.integer "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_habits_on_user_id"
  end

  create_table "notification_preferences", force: :cascade do |t|
    t.integer "user_id", null: false
    t.boolean "email_enabled", default: true, null: false
    t.boolean "push_enabled", default: true, null: false
    t.boolean "sms_enabled", default: false, null: false
    t.string "email_frequency", default: "immediately", null: false
    t.string "push_frequency", default: "immediately", null: false
    t.string "sms_frequency", default: "immediately", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_notification_preferences_on_user_id"
  end

  create_table "notification_schedules", force: :cascade do |t|
    t.integer "notification_id", null: false
    t.string "schedule_type", null: false
    t.string "frequency", null: false
    t.datetime "scheduled_at", null: false
    t.datetime "last_sent_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["frequency"], name: "index_notification_schedules_on_frequency"
    t.index ["notification_id"], name: "index_notification_schedules_on_notification_id"
    t.index ["schedule_type"], name: "index_notification_schedules_on_schedule_type"
    t.index ["scheduled_at"], name: "index_notification_schedules_on_scheduled_at"
  end

  create_table "notifications", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "title", null: false
    t.text "body", null: false
    t.string "notification_type", null: false
    t.string "status", default: "pending", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["notification_type"], name: "index_notifications_on_notification_type"
    t.index ["status"], name: "index_notifications_on_status"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username"
    t.string "password_digest"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "full_name"
    t.string "email"
    t.text "bio"
    t.string "timezone"
    t.string "avatar"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  add_foreign_key "habit_logs", "habits"
  add_foreign_key "habit_logs", "users"
  add_foreign_key "habits", "users"
  add_foreign_key "notification_preferences", "users"
  add_foreign_key "notification_schedules", "notifications"
  add_foreign_key "notifications", "users"
end
