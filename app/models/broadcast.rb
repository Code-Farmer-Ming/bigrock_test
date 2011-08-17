# == Schema Information
#
# Table name: broadcasts
#
#  id                 :integer       not null, primary key
#  user_id            :integer       not null
#  memo               :string(64)    default("")
#  broadcastable_type :string(255)   default(""), not null
#  broadcastable_id   :integer       not null
#  created_at         :datetime      
#  updated_at         :datetime      
#

class Broadcast < ActiveRecord::Base
  belongs_to :broadcastable,:polymorphic => true
  belongs_to :user
  
  has_many :user_broadcasts,:dependent=>:destroy
  #接收广播的用户
  has_many :receved_users,:through=>:user_broadcasts,:source=>:user

  def after_create
     self.user_broadcasts << UserBroadcast.new(:user=>self.user,:is_read=>true)
  end
  
end
