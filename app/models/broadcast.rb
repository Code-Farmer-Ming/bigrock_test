class Broadcast < ActiveRecord::Base
  belongs_to :broadcastable,:polymorphic => true
  belongs_to :user
  
  has_many :user_broadcasts,:dependent=>:destroy
  #接收广播的用户
  has_many :receved_users,:through=>:user_broadcasts,:source=>:user

  
end
