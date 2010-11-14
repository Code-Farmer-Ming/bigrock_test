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

ActiveRecord::Schema.define(:version => 20101101135035) do

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

  add_index "attachments", ["type", "master_id"], :name => "index_attachments_on_type_and_master_id", :unique => true

  create_table "attentions", :force => true do |t|
    t.integer  "user_id"
    t.integer  "target_id"
    t.string   "target_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "attentions", ["user_id", "target_id", "target_type"], :name => "index_attentions_on_user_id_and_target_id_and_target_type", :unique => true

  create_table "cities", :force => true do |t|
    t.integer "state_id",               :null => false
    t.string  "name",     :limit => 32
  end

  add_index "cities", ["name"], :name => "index_cities_on_name"

  create_table "comments", :force => true do |t|
    t.integer  "commentable_id",                  :null => false
    t.integer  "up",               :default => 0
    t.integer  "down",             :default => 0
    t.string   "content",                         :null => false
    t.integer  "user_id",                         :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "commentable_type"
  end

  add_index "comments", ["commentable_type", "commentable_id"], :name => "index_comments_on_commentable_type_and_commentable_id", :unique => true

  create_table "companies", :force => true do |t|
    t.string   "name",                 :default => ""
    t.text     "description"
    t.string   "website",              :default => ""
    t.string   "address",              :default => ""
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
    t.integer  "industry_root_id"
    t.integer  "industry_second_id"
    t.integer  "industry_third_id"
    t.integer  "industry_id"
    t.integer  "company_type_id"
    t.integer  "company_size_id"
    t.integer  "state_id"
    t.integer  "city_id"
    t.integer  "topics_count",         :default => 0,  :null => false
    t.integer  "jobs_count",           :default => 0
  end

  add_index "companies", ["name"], :name => "index_companies_on_name"

  create_table "company_judges", :force => true do |t|
    t.integer  "company_id"
    t.integer  "user_id"
    t.integer  "salary_value",    :default => 0
    t.integer  "condition_value", :default => 0
    t.text     "description"
    t.boolean  "anonymous",       :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "company_judges", ["company_id", "user_id"], :name => "index_company_judges_on_company_id_and_user_id", :unique => true

  create_table "company_sizes", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "company_sizes", ["name"], :name => "index_company_sizes_on_name"

  create_table "company_types", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "company_types", ["name"], :name => "index_company_types_on_name"

  create_table "company_versions", :force => true do |t|
    t.integer  "company_id"
    t.integer  "version"
    t.string   "name",        :default => ""
    t.text     "description"
    t.string   "website",     :default => ""
    t.string   "address",     :default => ""
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "company_versions", ["company_id"], :name => "index_company_versions_on_company_id"

  create_table "educations", :force => true do |t|
    t.date     "begin_date"
    t.date     "end_date"
    t.text     "description"
    t.integer  "resume_id"
    t.string   "degree"
    t.string   "major"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "school_id",   :null => false
  end

  add_index "educations", ["resume_id", "school_id"], :name => "index_educations_on_resume_id_and_school_id", :unique => true

  create_table "friends", :force => true do |t|
    t.integer  "user_id"
    t.integer  "friend_id"
    t.integer  "friend_type", :default => 1
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "friends", ["user_id", "friend_id"], :name => "index_friends_on_user_id_and_friend_id", :unique => true

  create_table "group_types", :force => true do |t|
    t.string   "name",       :limit => 16
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "groups", :force => true do |t|
    t.string   "name",                                          :null => false
    t.text     "description",                                   :null => false
    t.integer  "group_type_id",                                 :null => false
    t.string   "join_type",        :limit => 16,                :null => false
    t.integer  "create_user_id",                                :null => false
    t.integer  "members_count",                  :default => 0
    t.integer  "topics_count",                   :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "recommends_count",               :default => 0
  end

  add_index "groups", ["name"], :name => "index_groups_on_name"

  create_table "industries", :force => true do |t|
    t.string "name"
  end

  add_index "industries", ["name"], :name => "index_industries_on_name"

  create_table "job_applicants", :force => true do |t|
    t.integer  "job_id",                                     :null => false
    t.integer  "applicant_id",                               :null => false
    t.integer  "recommend_id"
    t.string   "memo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_deleted_by_published", :default => false
    t.boolean  "is_deleted_by_applicant", :default => false
    t.boolean  "is_read",                 :default => false
  end

  create_table "job_titles", :force => true do |t|
    t.integer  "company_id"
    t.string   "name",       :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "jobs", :force => true do |t|
    t.string   "title",                            :null => false
    t.string   "type_id",                          :null => false
    t.text     "job_description",                  :null => false
    t.text     "skill_description"
    t.integer  "state_id",                         :null => false
    t.integer  "city_id",                          :null => false
    t.integer  "job_title_id"
    t.datetime "end_at",                           :null => false
    t.integer  "create_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "company_id"
    t.integer  "view_count",        :default => 0
    t.integer  "applicants_count",  :default => 0
    t.integer  "comments_count",    :default => 0
  end

  create_table "judges", :force => true do |t|
    t.integer  "pass_id"
    t.integer  "user_id"
    t.integer  "judger_id"
    t.integer  "creditability_value", :default => 0
    t.integer  "ability_value",       :default => 0
    t.integer  "eq_value",            :default => 0
    t.text     "description"
    t.boolean  "anonymous",           :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "judges", ["pass_id", "user_id", "judger_id"], :name => "index_judges_on_pass_id_and_user_id_and_judger_id", :unique => true

  create_table "log_items", :force => true do |t|
    t.string   "logable_type"
    t.integer  "logable_id"
    t.string   "log_type"
    t.string   "operation"
    t.string   "changes"
    t.integer  "owner_id"
    t.string   "owner_type"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "members", :force => true do |t|
    t.integer  "group_id",                                       :null => false
    t.integer  "user_id",                                        :null => false
    t.string   "type",       :limit => 18, :default => "Normal"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "members", ["group_id", "user_id"], :name => "index_members_on_group_id_and_user_id", :unique => true

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
    t.integer  "parent_id",                  :default => 0
  end

  create_table "my_languages", :force => true do |t|
    t.string   "content",    :limit => 64
    t.integer  "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "is_current",               :default => false
  end

  create_table "need_jobs", :force => true do |t|
    t.string   "title"
    t.string   "description"
    t.integer  "state_id"
    t.integer  "city_id"
    t.integer  "poster_id"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "news", :force => true do |t|
    t.integer  "company_id",                                     :null => false
    t.string   "title",             :limit => 64,                :null => false
    t.text     "content",                                        :null => false
    t.integer  "create_user_id",                                 :null => false
    t.integer  "last_edit_user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "up",                              :default => 0
    t.integer  "down",                            :default => 0
    t.integer  "comments_count",                  :default => 0
    t.integer  "recommends_count",                :default => 0
    t.integer  "view_count",                      :default => 0
    t.datetime "last_edit_at"
  end

  create_table "passes", :force => true do |t|
    t.integer  "company_id"
    t.integer  "resume_id"
    t.integer  "user_id"
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
    t.integer  "job_title_id",        :default => 0
  end

  add_index "passes", ["company_id", "resume_id", "user_id"], :name => "index_passes_on_company_id_and_resume_id_and_user_id", :unique => true

  create_table "recommends", :force => true do |t|
    t.integer  "user_id",                                          :null => false
    t.string   "memo",               :limit => 64, :default => ""
    t.string   "recommendable_type",                               :null => false
    t.integer  "recommendable_id",                                 :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "recommends", ["user_id", "recommendable_type", "recommendable_id"], :name => "index_recommendable_user", :unique => true

  create_table "requisitions", :force => true do |t|
    t.integer  "applicant_id"
    t.integer  "respondent_id"
    t.string   "type"
    t.string   "memo"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "applicant_type", :null => false
  end

  add_index "requisitions", ["applicant_id", "respondent_id", "applicant_type", "type"], :name => "index_requisition_applicant", :unique => true

  create_table "resumes", :force => true do |t|
    t.string   "name"
    t.string   "type_name",        :limit => 18
    t.integer  "user_id"
    t.string   "user_name",        :limit => 18
    t.date     "birthday"
    t.boolean  "sex"
    t.string   "address"
    t.string   "mobile"
    t.string   "telephone"
    t.string   "phone3"
    t.string   "phone4"
    t.string   "blog_website"
    t.string   "personal_website"
    t.string   "website3"
    t.string   "website4"
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
    t.integer  "city_id"
    t.integer  "state_id"
  end

  create_table "schools", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "schools", ["name"], :name => "index_schools_on_name"

  create_table "skills", :force => true do |t|
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "skills", ["name"], :name => "index_skills_on_name"

  create_table "specialities", :force => true do |t|
    t.string   "description"
    t.integer  "resume_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "skill_id",    :null => false
  end

  add_index "specialities", ["resume_id", "skill_id"], :name => "index_specialities_on_resume_id_and_skill_id", :unique => true

  create_table "states", :force => true do |t|
    t.string "name", :limit => 32
  end

  add_index "states", ["name"], :name => "index_states_on_name"

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
    t.string   "title",                 :limit => 128
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
    t.integer  "recommends_count",                     :default => 0
  end

  add_index "topics", ["owner_type", "owner_id"], :name => "index_topics_on_owner_type_and_owner_id"

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

  add_index "user_settings", ["user_id"], :name => "index_user_settings_on_user_id", :unique => true

  create_table "user_tags", :force => true do |t|
    t.integer  "user_id",    :null => false
    t.integer  "tagging_id", :null => false
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "users", :force => true do |t|
    t.string   "nick_name",                :default => "马甲",  :null => false
    t.string   "email",                                           :null => false
    t.string   "password",                                        :null => false
    t.string   "title",                    :default => ""
    t.boolean  "is_active",                :default => false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "parent_id",                :default => 0,         :null => false
    t.string   "state",      :limit => 12, :default => "freedom"
    t.string   "salt",                                            :null => false
  end

  create_table "votes", :force => true do |t|
    t.integer  "owner_id"
    t.string   "owner_type"
    t.integer  "user_id"
    t.integer  "value",      :default => 0
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  add_index "votes", ["owner_id", "owner_type", "user_id"], :name => "index_votes_on_owner_id_and_owner_type_and_user_id", :unique => true

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
