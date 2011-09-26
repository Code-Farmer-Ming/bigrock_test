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
  validates_uniqueness_of :user_id, :scope =>:friend_id,:message =>"�Ѿ��Ǻ�����"
  
  belongs_to :user,:class_name=>"User",:foreign_key=>"user_id"
  belongs_to :friend,:class_name=>"User",:foreign_key=>"friend_id"
  acts_as_logger :log_action=>["create","destroy"],:owner_attribute=>"user",:logable=>"friend"

  def after_create
    msg= Msg.new_system_msg(:title=>"ϵͳ��ʾ��#{user.name}�Ѿ�����Ϊ����",:content=>"#{user.name}�Ѿ�����Ϊ����,ȥ�����ɡ�")
    msg.send_to(friend)
  end
  
  def self.per_page
    20
  end


end