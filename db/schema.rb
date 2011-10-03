# This file is auto-generated from the current state of the database. Instead of editing this file, 
# please use the migrations feature of Active Record to incrementally modify your database, and
# then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your database schema. If you need
# to create the application database on another system, you should be using db:schema:load, not running
# all the migrations from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20110127102836) do

  create_table "account_entries", :force => true do |t|
    t.integer  "debit"
    t.integer  "credit"
    t.string   "aasm_state"
    t.string   "reason"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "service_id"
    t.integer  "wallet_id"
    t.string   "response_ref"
    t.integer  "error_code"
  end

  create_table "adverts", :force => true do |t|
    t.string   "title"
    t.date     "run_from"
    t.date     "run_to"
    t.string   "image"
    t.integer  "views",      :default => 0
    t.integer  "clicks",     :default => 0
    t.string   "send_to"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "applications", :force => true do |t|
    t.string   "title"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "audits", :force => true do |t|
    t.integer  "auditable_id"
    t.string   "auditable_type"
    t.integer  "user_id"
    t.string   "user_type"
    t.string   "username"
    t.string   "action"
    t.text     "changes"
    t.integer  "version",        :default => 0
    t.datetime "created_at"
  end

  add_index "audits", ["auditable_id", "auditable_type"], :name => "auditable_index"
  add_index "audits", ["created_at"], :name => "index_audits_on_created_at"
  add_index "audits", ["user_id", "user_type"], :name => "user_index"

  create_table "billing_entries", :force => true do |t|
    t.string   "code"
    t.string   "reference"
    t.string   "reason"
    t.integer  "account_entry_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blogs", :force => true do |t|
    t.string   "title"
    t.text     "body"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comments_count", :default => 0
  end

  add_index "blogs", ["profile_id"], :name => "index_blogs_on_profile_id"

  create_table "business_card_profiles", :force => true do |t|
    t.integer "business_card_id"
    t.integer "profile_id"
    t.boolean "sync_to_phone",    :default => false
  end

  create_table "business_card_requests", :force => true do |t|
    t.integer  "requester_id"
    t.integer  "requested_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chat_invitations", :force => true do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "chats", :force => true do |t|
    t.integer  "profile_id"
    t.string   "topic"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "jabber_password"
    t.string   "chat_id"
    t.string   "to"
  end

  create_table "client_applications", :force => true do |t|
    t.string   "name"
    t.string   "url"
    t.string   "support_url"
    t.string   "callback_url"
    t.string   "key",          :limit => 50
    t.string   "secret",       :limit => 50
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "client_applications", ["key"], :name => "index_client_applications_on_key", :unique => true

  create_table "comments", :force => true do |t|
    t.text     "comment"
    t.datetime "created_at",                          :null => false
    t.datetime "updated_at",                          :null => false
    t.integer  "profile_id"
    t.string   "commentable_type", :default => "",    :null => false
    t.integer  "commentable_id",                      :null => false
    t.integer  "is_denied",        :default => 0,     :null => false
    t.boolean  "is_reviewed",      :default => false
  end

  add_index "comments", ["commentable_id", "commentable_type"], :name => "index_comments_on_commentable_id_and_commentable_type"
  add_index "comments", ["profile_id"], :name => "index_comments_on_profile_id"

  create_table "dating_profiles", :force => true do |t|
    t.integer  "profile_id"
    t.string   "seeking"
    t.integer  "age_lowest"
    t.integer  "age_highest"
    t.string   "for"
    t.string   "sign"
    t.integer  "from_international_dialing_code_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "international_dialing_code_id"
    t.string   "interests"
    t.string   "gender"
    t.string   "likes"
    t.string   "dislikes"
    t.integer  "age"
    t.datetime "last_billed"
  end

  create_table "delayed_jobs", :force => true do |t|
    t.integer  "priority",   :default => 0
    t.integer  "attempts",   :default => 0
    t.text     "handler"
    t.string   "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string   "locked_by"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "device_attributes", :force => true do |t|
    t.integer  "device_id"
    t.string   "name"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "device_content", :force => true do |t|
    t.string   "vendor",            :limit => 100
    t.string   "model",             :limit => 100
    t.text     "sync_instructions"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "device_content", ["vendor", "model"], :name => "vendor_model_unique", :unique => true

  create_table "devices", :force => true do |t|
    t.string   "user_agent"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "stylesheet_level",        :default => "mid"
    t.boolean  "use_external_stylesheet", :default => true
  end

  add_index "devices", ["user_agent"], :name => "index_devices_on_user_agent"

  create_table "facebook_statuses", :force => true do |t|
    t.integer  "profile_id"
    t.string   "text"
    t.string   "name"
    t.string   "facebook_uid"
    t.string   "pic_square"
    t.datetime "posted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_id",    :limit => 8
  end

  add_index "facebook_statuses", ["status_id"], :name => "index_facebook_statuses_on_status_id", :unique => true

  create_table "feed_items", :force => true do |t|
    t.boolean  "include_comments",                                 :default => false, :null => false
    t.boolean  "is_public",                                        :default => false, :null => false
    t.integer  "item_id"
    t.string   "item_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
    t.decimal  "latitude",         :precision => 15, :scale => 10
    t.decimal  "longitude",        :precision => 15, :scale => 10
  end

  add_index "feed_items", ["item_id", "item_type"], :name => "index_feed_items_on_item_id_and_item_type"

  create_table "feeds", :force => true do |t|
    t.integer "profile_id"
    t.integer "feed_item_id"
  end

  add_index "feeds", ["profile_id", "feed_item_id"], :name => "index_feeds_on_profile_id_and_feed_item_id"

  create_table "followships", :force => true do |t|
    t.integer  "follower_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "followed_id"
    t.boolean  "text_message_enabled", :default => false
  end

  create_table "forum_posts", :force => true do |t|
    t.text     "body"
    t.integer  "owner_id"
    t.integer  "topic_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "forum_posts", ["topic_id"], :name => "index_forum_posts_on_topic_id"

  create_table "forum_topics", :force => true do |t|
    t.string   "title"
    t.integer  "forum_id"
    t.integer  "owner_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "forum_topics", ["forum_id"], :name => "index_forum_topics_on_forum_id"

  create_table "forums", :force => true do |t|
    t.string   "name"
    t.text     "description"
    t.integer  "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friends", :force => true do |t|
    t.integer  "inviter_id"
    t.integer  "invited_id"
    t.integer  "status",     :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "state"
  end

  add_index "friends", ["invited_id", "inviter_id"], :name => "index_friends_on_invited_id_and_inviter_id", :unique => true
  add_index "friends", ["inviter_id", "invited_id"], :name => "index_friends_on_inviter_id_and_invited_id", :unique => true

  create_table "friendships", :force => true do |t|
    t.integer  "friender_id"
    t.integer  "friendee_id"
    t.string   "state"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "online",      :default => false
  end

  create_table "global_feed_items", :force => true do |t|
    t.integer  "profile_id"
    t.string   "message"
    t.integer  "comments_count"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_invitations", :force => true do |t|
    t.integer  "group_id"
    t.integer  "inviter_id"
    t.integer  "invitee_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_messages", :force => true do |t|
    t.integer  "group_id"
    t.string   "text"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.integer  "owner_id"
    t.boolean  "is_public",      :default => false
    t.string   "name"
    t.string   "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "kontacts_count"
  end

  create_table "groups_profiles", :id => false, :force => true do |t|
    t.integer "profile_id"
    t.integer "group_id"
  end

  create_table "help", :force => true do |t|
    t.string   "controller", :limit => 100
    t.string   "action",     :limit => 100
    t.text     "content"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "help", ["controller", "action"], :name => "controller_action_unique", :unique => true

  create_table "help_users", :id => false, :force => true do |t|
    t.integer "help_id"
    t.integer "user_id"
  end

  create_table "international_dialing_codes", :force => true do |t|
    t.string   "code"
    t.string   "country"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "invitations", :force => true do |t|
    t.integer  "profile_id"
    t.integer  "kontact_id"
    t.string   "code"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jabber_messages", :force => true do |t|
    t.integer  "from_id"
    t.integer  "to_id"
    t.string   "message"
    t.boolean  "read",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
  end

  create_table "kontact_informations", :force => true do |t|
    t.string   "display_name"
    t.string   "formatted_name"
    t.string   "family_name"
    t.string   "given_name"
    t.string   "middle_name"
    t.string   "honorific_prefix"
    t.string   "honorific_suffix"
    t.string   "nickname"
    t.string   "birthday"
    t.date     "anniversary"
    t.string   "gender"
    t.string   "note"
    t.string   "preferred_username"
    t.datetime "utc_offset"
    t.boolean  "connected"
    t.decimal  "longitude",                        :precision => 15, :scale => 10
    t.decimal  "latitude",                         :precision => 15, :scale => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.string   "icon"
    t.string   "location"
    t.text     "about_me"
    t.string   "digest"
    t.string   "luid"
    t.string   "organization"
    t.string   "type",                                                             :default => "KontactInformation"
    t.string   "uuid",               :limit => 36
  end

  add_index "kontact_informations", ["created_at"], :name => "index_kontact_informations_on_created_at"
  add_index "kontact_informations", ["id"], :name => "index_kontact_informations_on_id", :unique => true
  add_index "kontact_informations", ["updated_at"], :name => "index_kontact_informations_on_updated_at"
  add_index "kontact_informations", ["uuid"], :name => "index_kontact_informations_on_uuid"

  create_table "kontacts", :force => true do |t|
    t.integer  "parent_id"
    t.string   "parent_type"
    t.integer  "kontact_information_id"
    t.string   "status"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "kontacts", ["parent_id"], :name => "index_kontacts_on_parent_id"
  add_index "kontacts", ["parent_type"], :name => "index_kontacts_on_parent_type"

  create_table "locations", :force => true do |t|
    t.string   "title"
    t.decimal  "latitude",       :precision => 15, :scale => 10
    t.decimal  "longitude",      :precision => 15, :scale => 10
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "profile_id"
    t.string   "static_map_url"
    t.integer  "comments_count",                                 :default => 0
  end

  create_table "messages", :force => true do |t|
    t.string   "subject"
    t.text     "body"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "sender_id"
    t.integer  "receiver_id"
    t.boolean  "read",          :default => false,     :null => false
    t.string   "sender_type"
    t.string   "receiver_type"
    t.string   "type",          :default => "Message"
    t.string   "icon"
    t.boolean  "saveto_inbox",  :default => false
  end

  add_index "messages", ["receiver_id"], :name => "index_messages_on_receiver_id"
  add_index "messages", ["sender_id"], :name => "index_messages_on_sender_id"

  create_table "oauth_nonces", :force => true do |t|
    t.string   "nonce"
    t.integer  "timestamp"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_nonces", ["nonce", "timestamp"], :name => "index_oauth_nonces_on_nonce_and_timestamp", :unique => true

  create_table "oauth_tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "type",                  :limit => 20
    t.integer  "client_application_id"
    t.string   "token",                 :limit => 50
    t.string   "secret",                :limit => 50
    t.datetime "authorized_at"
    t.datetime "invalidated_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "oauth_tokens", ["token"], :name => "index_oauth_tokens_on_token", :unique => true

  create_table "photos", :force => true do |t|
    t.string   "caption",        :limit => 1000
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "profile_id"
    t.string   "image"
    t.integer  "comments_count"
    t.decimal  "latitude",                       :precision => 15, :scale => 10
    t.decimal  "longitude",                      :precision => 15, :scale => 10
  end

  add_index "photos", ["profile_id"], :name => "index_photos_on_profile_id"

  create_table "plural_fields", :force => true do |t|
    t.string   "type"
    t.string   "value"
    t.string   "field_type"
    t.boolean  "primary"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "kontact_information_id"
  end

  add_index "plural_fields", ["field_type"], :name => "index_plural_fields_on_field_type"
  add_index "plural_fields", ["kontact_information_id"], :name => "index_plural_fields_on_kontact_information_id"
  add_index "plural_fields", ["type"], :name => "index_plural_fields_on_type"

  create_table "profile_statuses", :force => true do |t|
    t.integer  "profile_id"
    t.string   "text",                :limit => 140,                                                    :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "comments_count",                                                     :default => 0
    t.decimal  "latitude",                           :precision => 15, :scale => 10
    t.decimal  "longitude",                          :precision => 15, :scale => 10
    t.string   "twitter_status_id"
    t.string   "facebook_status_id"
    t.string   "fb_post_status"
    t.string   "twitter_post_status"
    t.boolean  "saveto_inbox",                                                       :default => false
  end

  create_table "profiles", :force => true do |t|
    t.integer  "user_id"
    t.string   "location"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "email"
    t.boolean  "is_active",                                                     :default => false
    t.datetime "last_activity_at"
    t.decimal  "lat",                           :precision => 15, :scale => 10
    t.decimal  "lng",                           :precision => 15, :scale => 10
    t.datetime "last_checkin"
    t.string   "display_name"
    t.string   "family_name"
    t.string   "given_name"
    t.string   "middle_name"
    t.string   "gender"
    t.date     "birthday"
    t.string   "mobile"
    t.text     "about_me"
    t.string   "icon"
    t.integer  "kontacts_count"
    t.string   "last_user_agent"
    t.boolean  "sort_contacts_last_name_first",                                 :default => true
    t.boolean  "completion_bonus_awarded",                                      :default => false
    t.integer  "followed_ships_count",                                          :default => 0
    t.integer  "follower_ships_count",                                          :default => 0
    t.integer  "birthyear"
    t.string   "description"
    t.string   "interest"
    t.string   "relation_status"
  end

  add_index "profiles", ["user_id"], :name => "index_profiles_on_user_id"

  create_table "public_feed_items", :force => true do |t|
    t.integer  "item_id"
    t.string   "item_type"
    t.decimal  "latitude",   :precision => 15, :scale => 10
    t.decimal  "longitude",  :precision => 15, :scale => 10
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "services", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "price_in_cents"
    t.integer  "credit"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "sts_service_id"
    t.boolean  "active",         :default => false
    t.integer  "debit",          :default => 0
    t.string   "bill_to"
  end

  create_table "sessions", :force => true do |t|
    t.string   "session_id"
    t.text     "data"
    t.datetime "updated_at"
  end

  add_index "sessions", ["session_id"], :name => "index_sessions_on_session_id"
  add_index "sessions", ["updated_at"], :name => "index_sessions_on_updated_at"

  create_table "settings", :force => true do |t|
    t.integer  "user_id"
    t.string   "twitter_login"
    t.string   "twitter_password"
    t.boolean  "send_status_to_facebook",        :default => false
    t.boolean  "upload_photos_to_facebook",      :default => false
    t.string   "fireeagle_request_token"
    t.string   "fireeagle_request_token_secret"
    t.string   "fireeagle_access_token"
    t.string   "fireeagle_access_token_secret"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "show_in_public_searches",        :default => true
    t.boolean  "show_in_public_timeline",        :default => true
    t.string   "facebook_infinite_session"
    t.string   "last_tweet_id"
    t.string   "facebook_uid"
    t.string   "last_facebook_status_id"
    t.datetime "last_twitter_check"
    t.boolean  "send_status_to_twitter"
    t.string   "twitter_oauth_token"
    t.string   "twitter_oauth_secret"
    t.boolean  "facebook_session_expired",       :default => false
    t.string   "facebook_access_token"
  end

  create_table "shortlinks", :force => true do |t|
    t.string   "href"
    t.string   "href_code"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "click_count", :default => 0
  end

  add_index "shortlinks", ["href"], :name => "index_shortlinks_on_href"
  add_index "shortlinks", ["href_code"], :name => "index_shortlinks_on_href_code"

  create_table "subscription_billing_entries", :force => true do |t|
    t.string   "code"
    t.string   "reference"
    t.string   "reason"
    t.integer  "profile_id"
    t.integer  "service_id"
    t.string   "aasm_state"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "taggings", :force => true do |t|
    t.integer  "tag_id"
    t.integer  "taggable_id"
    t.integer  "tagger_id"
    t.string   "tagger_type"
    t.string   "taggable_type"
    t.string   "context"
    t.datetime "created_at"
  end

  add_index "taggings", ["tag_id"], :name => "index_taggings_on_tag_id"
  add_index "taggings", ["taggable_id", "taggable_type", "context"], :name => "index_taggings_on_taggable_id_and_taggable_type_and_context"

  create_table "tags", :force => true do |t|
    t.string "name"
  end

  create_table "text_messages", :force => true do |t|
    t.string   "to"
    t.string   "message"
    t.boolean  "sent"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "href"
    t.integer  "recipient_id"
    t.boolean  "billable",     :default => true
    t.integer  "billed_to_id"
    t.integer  "cost",         :default => 1
    t.integer  "service_id"
  end

  create_table "twitter_statuses", :force => true do |t|
    t.integer  "profile_id"
    t.string   "text"
    t.string   "name"
    t.string   "screen_name"
    t.string   "avatar_url"
    t.datetime "posted_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "status_id",   :limit => 8, :null => false
  end

  add_index "twitter_statuses", ["status_id"], :name => "index_twitter_statuses_on_status_id", :unique => true

  create_table "users", :force => true do |t|
    t.string   "login"
    t.string   "crypted_password",               :limit => 40
    t.string   "salt",                           :limit => 40
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "remember_token"
    t.datetime "remember_token_expires_at"
    t.boolean  "is_admin"
    t.boolean  "can_send_messages",                            :default => true
    t.string   "email_verification"
    t.boolean  "email_verified"
    t.string   "activation_code",                :limit => 40
    t.datetime "activated_at"
    t.string   "state",                                        :default => "passive"
    t.datetime "deleted_at"
    t.string   "mobile_activation_code"
    t.datetime "mobile_activated_at"
    t.datetime "last_sync_started"
    t.datetime "last_sync_finished"
    t.text     "sync_xml"
    t.string   "fireeagle_request_token"
    t.string   "fireeagle_request_token_secret"
    t.string   "fireeagle_access_token"
    t.string   "fireeagle_access_token_secret"
    t.string   "twitter_login"
    t.string   "twitter_password"
    t.boolean  "online",                                       :default => false
    t.datetime "remind_to_sync_date"
    t.boolean  "password_reminder"
    t.string   "password_reset_code",            :limit => 8
    t.integer  "fb_id"
    t.string   "email_hash"
    t.integer  "fb_user_id",                     :limit => 8
    t.integer  "login_count"
  end

  add_index "users", ["login"], :name => "index_users_on_login"

  create_table "wallets", :force => true do |t|
    t.integer  "balance"
    t.integer  "profile_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "reserve",    :default => 0
  end

  create_table "wurfl_capabilities", :force => true do |t|
    t.integer "wurfl_device_id",                :null => false
    t.string  "name",            :limit => 128, :null => false
    t.string  "value",           :limit => 128, :null => false
  end

  add_index "wurfl_capabilities", ["name"], :name => "index_wurfl_capabilities_on_name"

  create_table "wurfl_devices", :force => true do |t|
    t.string   "xml_id",             :limit => 128, :null => false
    t.string   "user_agent"
    t.string   "fall_back",          :limit => 128
    t.integer  "actual_device_root"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "wurfl_devices", ["xml_id"], :name => "index_wurfl_devices_on_xml_id"

end
