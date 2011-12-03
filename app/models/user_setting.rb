# == Schema Information
#
# Table name: user_settings
#
#  id                          :integer       not null, primary key
#  user_id                     :integer       
#  all_resume_visibility       :string(255)   default("公开")
#  img_visibility              :string(255)   default("公开")
#  edu_summary_visibility      :string(255)   default("公开")
#  pass_summary_visibility     :string(255)   default("公开")
#  sex_visibility              :string(255)   default("公开")
#  birthday_visibility         :string(255)   default("公开")
#  blog_site_visibility        :string(255)   default("公开")
#  web_site_visibility         :string(255)   default("公开")
#  msn_visibility              :string(255)   default("公开")
#  qq_visibility               :string(255)   default("公开")
#  address_visibility          :string(255)   default("公开")
#  mobile_visibility           :string(255)   default("公开")
#  phone_visibility            :string(255)   default("公开")
#  self_description_visibility :string(255)   default("公开")
#  pass_visibility             :string(255)   default("公开")
#  work_item_visibility        :string(255)   default("公开")
#  judge_visibility            :string(255)   default("公开")
#  edu_visibility              :string(255)   default("公开")
#  speciality_visibility       :string(255)   default("公开")
#  created_at                  :datetime      
#  updated_at                  :datetime      
#  apply_friend_auth           :string(255)   default("允许")
#

class UserSetting < ActiveRecord::Base
  belongs_to :user,:class_name=>"User",:foreign_key => "user_id"
  VISIBILITY_TYPES=["公开", "好友和同事"]
  APPLY_FRIEND_TYPES=["允许","不允许"]
 

  def can_see_resume(user)
    self["all_resume_visibility"]==UserSetting::VISIBILITY_TYPES[0] || self.user.my_follow_users.exists?(user) || self.user.id==user.id
  end
  #判断 用户是否有权限 查看
  #name 哪个权限 user 要判断的用户
  def can_visibility?(name,user)
    true
    #    if self.user !=user
    #      case (self[name])
    #      when UserSetting::VISIBILITY_TYPES[0] then return true
    #      when  UserSetting::VISIBILITY_TYPES[1] then return self.user.is_friend?(user)
    #      else
    #        return false
    #      end
    #    else
    #      true
    #    end
  end
end
