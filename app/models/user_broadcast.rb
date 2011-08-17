# == Schema Information
#
# Table name: user_broadcasts
#
#  id           :integer       not null, primary key
#  user_id      :integer       
#  broadcast_id :integer       
#  is_read      :boolean       
#  created_at   :datetime      
#  updated_at   :datetime      
#  poster_id    :integer       
#

class UserBroadcast < ActiveRecord::Base
  validates_uniqueness_of :user_id, :scope => :broadcast_id,:message =>"已经发送"
  belongs_to :user
  belongs_to :broadcast
  belongs_to :poster,:class_name=>"User",:foreign_key=>"poster_id"
  
  def read()
    self.is_read = true
    save
  end
  
  def after_create
    Msg.new_system_msg(:title=>"您关注的朋友[#{poster.name}]给你转发了一条信息",
      :content=>"<a href='/broadcasts' >点击查看</a>").
      send_to(user) unless is_read
  end
end
