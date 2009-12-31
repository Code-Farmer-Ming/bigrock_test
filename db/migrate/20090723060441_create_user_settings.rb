class CreateUserSettings < ActiveRecord::Migration
  def self.up
    create_table :user_settings do |t|
      t.integer :user_id
      t.string :all_resume_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :img_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :edu_summary_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :pass_summary_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :sex_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :birthday_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :blog_site_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :web_site_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :msn_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :qq_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :address_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :mobile_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :phone_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :self_description_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :pass_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :work_item_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :judge_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]
      t.string :edu_visibility, :default => UserSetting::VISIBILITY_TYPES[0]
      t.string :speciality_visibility,:default=> UserSetting::VISIBILITY_TYPES[0]

      t.timestamps
    end
  end

  def self.down
    drop_table :user_settings
  end
end
