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

ActiveRecord::Schema.define(version: 20171116050348) do

  create_table "authentication_tokens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "body"
    t.bigint "user_id"
    t.datetime "last_used_at"
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_authentication_tokens_on_user_id"
  end

  create_table "devices", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "device_id"
    t.string "device_name"
    t.string "access_token"
    t.integer "setting_id"
    t.datetime "last_sync"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "device_app_version"
    t.string "device_os_version"
    t.string "longitude"
    t.string "latitude"
    t.string "device_type"
    t.datetime "deleted_at"
    t.index ["access_token"], name: "index_devices_on_access_token"
    t.index ["deleted_at"], name: "index_devices_on_deleted_at"
    t.index ["device_id"], name: "index_devices_on_device_id"
    t.index ["setting_id"], name: "index_devices_on_setting_id"
  end

  create_table "jurnal_access_tokens", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "code"
    t.integer "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "payment_methods", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "payment_type_id"
    t.string "payment_type_name"
    t.integer "payment_account_id"
    t.string "payment_account_name"
    t.integer "payment_fee_account_id"
    t.string "payment_fee_account_name"
    t.integer "payment_fee_percentage"
    t.integer "payment_fee_fixed"
    t.integer "setting_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "token"
  end

  create_table "settings", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.integer "warehouse_id"
    t.string "warehouse_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.string "tag_ids"
    t.string "token"
  end

  create_table "transactions", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.integer "device_id"
    t.date "date"
    t.integer "transaction_id"
    t.decimal "amount", precision: 50, scale: 6
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "payment_id"
    t.integer "payment_method_id"
    t.string "transaction_no"
    t.string "custom_id"
    t.index ["custom_id"], name: "index_transactions_on_custom_id"
    t.index ["device_id", "transaction_id"], name: "index_transactions_on_device_id_and_transaction_id"
    t.index ["device_id"], name: "index_transactions_on_device_id"
    t.index ["transaction_id"], name: "index_transactions_on_transaction_id"
  end

  create_table "users", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "email", default: "", null: false
    t.string "name"
    t.string "logo_url"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.string "phone"
    t.string "fax"
    t.string "address"
    t.string "company_website"
    t.string "default_invoice_message"
    t.integer "person_id"
    t.string "company_package"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "authentication_tokens", "users"
end
