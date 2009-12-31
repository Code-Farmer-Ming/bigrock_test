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

ActiveRecord::Schema.define(:version => 20091229074446) do

  create_table "attachments", :force => true do |t|
    t.string   "filename"
    t.string   "type"
    t.string   "content_type"
    t.integer  "size"
    t.integer  "width"
    t.integer  "height"
    t.integer  "parent_id"
    t.string   "thumbnail"
    t.integer  "master_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "attentions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "cities", :force => true do |t|
    t.integer "state_id",               :null => false
    t.string  "name",     :limit => 32
  end

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id"
    t.integer  "up",               :default => 0
    t.integer  "down",             :default => 0
    t.string   "content"
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "commentable_type"
  end

  create_table "companies", :force => true do |t|
    t.string   "name",                 :default => ""
    t.text     "description"
    t.string   "website",              :default => ""
    t.integer  "create_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "version"
    t.integer  "salary_value",         :default => 0
    t.integer  "condition_value",      :default => 0
    t.integer  "company_judges_count", :default => 0
    t.string   "fax"
    t.string   "phone"
    t.integer  "last_edit_user_id"
    t.string   "address",              :default => ""
    t.integer  "industry_root_id"
    t.integer  "industry_second_id"
    t.integer  "industry_third_id"
    t.integer  "industry_id"
    t.integer  "company_type_id"
    t.integer  "company_size_id"
    t.integer  "state_id"
    t.integer  "city_id"
    t.integer  "topics_count",         :default => 0,  :null => false
  end

  create_table "company_judges", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "salary_value"
    t.integer  "condition_value"
    t.text     "description"
    t.boolean  "visiabled",       :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "anonymous",       :default => false
  end

  create_table "company_sizes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "company_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "company_versions", :force => true do |t|
    t.integer  "company_id"
    t.integer  "version"
    t.string   "name",                     :default => ""
    t.text     "description"
    t.string   "website",                  :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "address",                  :default => ""
    t.string   "fax",         :limit => 1
    t.string   "phone",       :limit => 1
  end

  add_index "company_versions", ["company_id"], :name => "index_company_versions_on_company_id"

  create_table "dict_city", :primary_key => "N_CITYID", :force => true do |t|
    t.string  "S_CITYNAME", :limit => 30, :null => false
    t.integer "N_PROVID",                 :null => false
    t.string  "S_STATE",    :limit => 1
  end

  create_table "dict_province", :primary_key => "N_PROVID", :force => true do |t|
    t.string "S_PROVNAME", :limit => 30, :null => false
    t.string "S_TYPE",     :limit => 1
    t.string "S_STATE",    :limit => 1
  end

  create_table "educations", :force => true do |t|
    t.string   "school_name"
    t.date     "begin_date"
    t.date     "end_date"
    t.text     "description"
    t.integer  "resume_id"
    t.string   "degree"
    t.string   "major"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friends", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.integer  "friend_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "group_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name",                          :null => false
    t.text     "description",                   :null => false
    t.integer  "group_type_id",                 :null => false
    t.string   "join_type",                     :null => false
    t.integer  "create_user_id",                :null => false
    t.integer  "members_count",  :default => 0
    t.integer  "topics_count",   :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "industries", :force => true do |t|
    t.string "name"
  end

  create_table "industry_roots", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "industry_seconds", :force => true do |t|
    t.integer  "industry_root_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "industry_thirds", :force => true do |t|
    t.integer  "industry_second_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "judges", :force => true do |t|
    t.integer  "pass_id"
    t.integer  "user_id"
    t.integer  "judger_id"
    t.integer  "creditability_value", :default => 0
    t.integer  "ability_value",       :default => 0
    t.integer  "eq_value",            :default => 0
    t.text     "description"
    t.boolean  "visiabled",           :default => true
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "anonymous",           :default => true
  end

  create_table "log_items", :force => true do |t|
    t.string   "logable_type"
    t.integer  "logable_id"
    t.string   "log_type"
    t.string   "changes"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "operation"
    t.string   "origin_value_type"
    t.integer  "origin_value_id"
  end

  create_table "members", :force => true do |t|
    t.integer  "group_id",                                        :null => false
    t.integer  "user_id",                                         :null => false
    t.string   "member_type", :limit => 18, :default => "normal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "msg_responses", :force => true do |t|
    t.integer  "msg_id"
    t.integer  "sender_id"
    t.string   "content"
    t.boolean  "is_check",   :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "msgs", :force => true do |t|
    t.integer  "sender_id",                                     :null => false
    t.integer  "sendee_id",                                     :null => false
    t.string   "title",       :limit => 128,                    :null => false
    t.string   "content",                                       :null => false
    t.boolean  "is_check",                   :default => false
    t.boolean  "sender_stop",                :default => false
    t.boolean  "sendee_stop",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "my_languages", :force => true do |t|
    t.string   "content",    :limit => 64
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_current",               :default => true
  end

  create_table "news", :force => true do |t|
    t.integer  "company_id"
    t.string   "title"
    t.text     "content"
    t.integer  "create_user_id"
    t.integer  "last_edit_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "up",                :default => 0
    t.integer  "down",              :default => 0
    t.integer  "comments_count"
  end

  create_table "passes", :force => true do |t|
    t.integer  "company_id"
    t.integer  "resume_id"
    t.integer  "user_id"
    t.string   "title"
    t.string   "department"
    t.date     "begin_date"
    t.date     "end_date"
    t.text     "work_description"
    t.boolean  "is_current",          :default => false
    t.integer  "creditability_value", :default => 0
    t.integer  "ability_value",       :default => 0
    t.integer  "eq_value",            :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "judges_count",        :default => 0
  end

  create_table "recommends", :force => true do |t|
    t.integer  "user_id",                            :null => false
    t.string   "memo",               :default => ""
    t.string   "recommendable_type",                 :null => false
    t.integer  "recommendable_id",                   :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "requisitions", :force => true do |t|
    t.integer  "applicant_id"
    t.integer  "respondent_id"
    t.string   "type"
    t.string   "memo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "applicant_type"
  end

  create_table "resumes", :force => true do |t|
    t.string   "name"
    t.string   "type_name",        :limit => 18
    t.integer  "user_id"
    t.string   "user_name",        :limit => 18
    t.date     "birthday"
    t.boolean  "sex"
    t.string   "address"
    t.string   "phone1"
    t.string   "phone2"
    t.string   "phone3"
    t.string   "phone4"
    t.string   "website1"
    t.string   "website2"
    t.string   "website3"
    t.string   "website4"
    t.string   "photo",                          :default => "imagesdefault_thumb.png"
    t.text     "self_description"
    t.string   "goal"
    t.string   "interests"
    t.string   "qq"
    t.string   "msn"
    t.string   "city"
    t.string   "industry"
    t.boolean  "is_current",                     :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "specialities", :force => true do |t|
    t.string   "name"
    t.string   "description"
    t.integer  "resume_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "states", :force => true do |t|
    t.string "name", :limit => 32
  end

  create_table "taggings", :force => true do |t|
    t.integer "tag_id",                         :null => false
    t.integer "taggable_id",                    :null => false
    t.string  "taggable_type",                  :null => false
    t.integer "user_tags_count", :default => 0, :null => false
  end

  add_index "taggings", ["tag_id", "taggable_id", "taggable_type"], :name => "index_taggings_on_tag_id_and_taggable_id_and_taggable_type", :unique => true

  create_table "tags", :force => true do |t|
    t.string "name", :null => false
  end

  add_index "tags", ["name"], :name => "index_tags_on_name", :unique => true

  create_table "tokens", :force => true do |t|
    t.integer  "user_id"
    t.string   "action"
    t.string   "value"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "topics", :force => true do |t|
    t.integer  "owner_id",                                                :null => false
    t.string   "owner_type",                                              :null => false
    t.integer  "author_id",                                               :null => false
    t.string   "title",                 :limit => 128,                    :null => false
    t.text     "content",                                                 :null => false
    t.integer  "up",                                   :default => 0
    t.integer  "down",                                 :default => 0
    t.integer  "comments_count",                       :default => 0
    t.integer  "view_count",                           :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "top_level",                            :default => false
    t.boolean  "can_comment",                          :default => true
    t.integer  "last_comment_user_id"
    t.datetime "last_comment_datetime"
  end

  create_table "user_settings", :force => true do |t|
    t.integer  "user_id"
    t.string   "all_resume_visibility",       :default => "公开"
    t.string   "img_visibility",              :default => "公开"
    t.string   "edu_summary_visibility",      :default => "公开"
    t.string   "pass_summary_visibility",     :default => "公开"
    t.string   "sex_visibility",              :default => "公开"
    t.string   "birthday_visibility",         :default => "公开"
    t.string   "blog_site_visibility",        :default => "公开"
    t.string   "web_site_visibility",         :default => "公开"
    t.string   "msn_visibility",              :default => "公开"
    t.string   "qq_visibility",               :default => "公开"
    t.string   "address_visibility",          :default => "公开"
    t.string   "mobile_visibility",           :default => "公开"
    t.string   "phone_visibility",            :default => "公开"
    t.string   "self_description_visibility", :default => "公开"
    t.string   "pass_visibility",             :default => "公开"
    t.string   "work_item_visibility",        :default => "公开"
    t.string   "judge_visibility",            :default => "公开"
    t.string   "edu_visibility",              :default => "公开"
    t.string   "speciality_visibility",       :default => "公开"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "apply_friend_auth",           :default => "允许"
  end

  create_table "user_tags", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "tagging_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                                            :null => false
    t.string   "password",                                         :null => false
    t.boolean  "is_active",                 :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "nick_name",  :limit => 128
    t.integer  "parent_id",                 :default => 0,         :null => false
    t.string   "state",      :limit => 12,  :default => "working"
  end

  create_table "work_items", :force => true do |t|
    t.string   "name"
    t.date     "begin_date"
    t.date     "end_date"
    t.text     "work_content"
    t.text     "work_description"
    t.integer  "pass_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

end
