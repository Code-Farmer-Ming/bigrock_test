# == Schema Information
#
# Table name: msg_responses
#
#  id         :integer       not null, primary key
#  msg_id     :integer       
#  sender_id  :integer       
#  content    :string(255)   
#  is_check   :boolean       
#  created_at :datetime      
#  updated_at :datetime      
#

class MsgResponse < ActiveRecord::Base
  validates_length_of :content, :within => 3..255
  
  belongs_to :msg
  belongs_to :sender,:class_name=>"User",:foreign_key=>"sender_id"
  def after_create
    MailerServer.deliver_get_new_msg(msg)
  end
  #已经标记回复阅读
  def make_read
    update_attribute("is_check", true) unless is_check
  end

end
