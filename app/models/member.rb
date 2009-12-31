# == Schema Information
#
# Table name: members
#
#  id          :integer       not null, primary key
#  group_id    :integer       not null
#  user_id     :integer       not null
#  member_type :string(18)    default("normal")
#  created_at  :datetime      
#  updated_at  :datetime      
#

class Member < ActiveRecord::Base
  #成员类型
  MEMBER_TYPES = ["root","manager","normal"]

  belongs_to :group,:counter_cache => true
  belongs_to :user ,:class_name=>"User",:foreign_key=>"user_id"
end
