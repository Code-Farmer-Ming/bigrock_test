# == Schema Information
#
# Table name: friends
#
#  id          :integer       not null, primary key
#  user_id     :integer       
#  friend_id   :integer       
#  friend_type :integer       default(1)
#  created_at  :datetime      
#  updated_at  :datetime      
#

class Friend < ActiveRecord::Base
  validates_uniqueness_of :user_id, :scope =>:friend_id,:message =>"已经是好友啦"
  
  belongs_to :user,:class_name=>"User",:foreign_key=>"user_id"
  belongs_to :friend,:class_name=>"User",:foreign_key=>"friend_id"
  acts_as_logger :log_action=>["create"],:owner_attribute=>"user",:logable=>"friend"
 
  def after_create
    msg= Msg.new_system_msg(:title=>"系统提示：#{user.name}已经加你为好友",:content=>"#{user.name}已经加你为好友,去看看吧。")
    msg.send_to(friend)
  end
end