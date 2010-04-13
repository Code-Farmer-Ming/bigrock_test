# == Schema Information
#
# Table name: members
#
#  id         :integer       not null, primary key
#  group_id   :integer       not null
#  user_id    :integer       not null
#  type       :string(18)    default("Normal")
#  created_at :datetime      
#  updated_at :datetime      
#

class Member < ActiveRecord::Base
  #成员类型
  MEMBER_TYPES = ["Root","Manager","Normal"]
  validates_uniqueness_of :user_id, :scope => :group_id,:message =>"已经加入小组啦"
    #记录修改 资料
  acts_as_logger :log_action=>["create"],:owner_attribute=>"user",:log_type=>"join_group",:logable=>"group",:can_log=>:"!user.is_alias?"
  
  belongs_to :group,:counter_cache => true
  belongs_to :user ,:class_name=>"User",:foreign_key=>"user_id"
end
