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

ActiveRecord::Schema.define(version: 20150210023516) do

  create_table "certificates", force: true do |t|
    t.integer  "purchaser_id"
    t.integer  "sponsorship_id"
    t.decimal  "donation_percentage", precision: 5,  scale: 2, default: 0.0
    t.decimal  "amount",              precision: 15, scale: 2
    t.string   "recipient"
    t.string   "redemption_code"
    t.boolean  "redeemed",                                     default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "serial_number"
  end

  add_index "certificates", ["purchaser_id"], name: "index_certificates_on_purchaser_id"
  add_index "certificates", ["sponsorship_id"], name: "index_certificates_on_sponsorship_id"

  create_table "sponsorships", force: true do |t|
    t.integer  "business_id"
    t.integer  "cause_id"
    t.datetime "resolved_at"
    t.integer  "status",      default: 0, null: false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "sponsorships", ["business_id"], name: "index_sponsorships_on_business_id"
  add_index "sponsorships", ["cause_id"], name: "index_sponsorships_on_cause_id"

  create_table "taggings", force: true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.string   "taggable_type"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "context",       limit: 128
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type", "context", "tagger_id", "tagger_type"], name: "taggings_idx", unique: true
  add_index "taggings", ["taggable_id", "taggable_type", "context"], name: "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", force: true do |t|
    t.string  "name"
    t.integer "taggings_count", default: 0
  end

  add_index "tags", ["name"], name: "index_tags_on_name", unique: true

  create_table "users", force: true do |t|
    t.string   "role",                                                             default: "individual"
    t.string   "first_name"
    t.string   "last_name"
    t.string   "email",                                                            default: "",           null: false
    t.string   "encrypted_password",                                               default: "",           null: false
    t.string   "authentication_token"
    t.string   "company_name"
    t.string   "street_address"
    t.string   "phone"
    t.string   "city"
    t.string   "state"
    t.string   "country",                                                          default: "Canada"
    t.string   "zip"
    t.boolean  "global_redeem",                                                    default: false
    t.text     "summary"
    t.text     "description"
    t.string   "website"
    t.string   "customer_id"
    t.string   "publishable_key"
    t.string   "provider"
    t.string   "uid"
    t.string   "access_code"
    t.string   "refresh_token"
    t.decimal  "balance",                                 precision: 15, scale: 2, default: 0.0
    t.decimal  "total_funds_raised",                      precision: 15, scale: 2, default: 0.0
    t.boolean  "is_activated",                                                     default: false
    t.boolean  "is_published",                                                     default: false
    t.boolean  "is_featured",                                                      default: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                                                    default: 0,            null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.string   "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string   "unconfirmed_email"
    t.boolean  "mailing_list_opt_in",                                              default: false
    t.boolean  "agree_to_tc",                                                      default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.datetime "deleted_at"
    t.string   "profile_picture_file_name"
    t.string   "profile_picture_content_type"
    t.integer  "profile_picture_file_size"
    t.datetime "profile_picture_updated_at"
    t.string   "twitter"
    t.integer  "sponsorship_rate",             limit: 15
  end

  add_index "users", ["authentication_token"], name: "index_users_on_authentication_token", unique: true
  add_index "users", ["company_name"], name: "company_name_index", unique: true
  add_index "users", ["confirmation_token"], name: "index_users_on_confirmation_token", unique: true
  add_index "users", ["email"], name: "index_users_on_email", unique: true
  add_index "users", ["id"], name: "index_users_on_id"
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true

end
