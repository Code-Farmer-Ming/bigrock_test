# == Schema Information
#
# Table name: msgs
#
#  id          :integer       not null, primary key
#  sender_id   :integer       not null
#  sendee_id   :integer       not null
#  title       :string(128)   default(""), not null
#  content     :string(255)   default(""), not null
#  is_check    :boolean       
#  sender_stop :boolean       
#  sendee_stop :boolean       
#  created_at  :datetime      
#  updated_at  :datetime      
#

class Msg < ActiveRecord::Base
  #消息 的回复
  has_many :msg_responses ,:class_name=>"MsgResponse",:dependent=>:destroy
  #发送者
  belongs_to :sender,:class_name=>"User",:foreign_key=>"sender_id"
  #接收者
  belongs_to :sendee,:class_name=>"User",:foreign_key=>"sendee_id"
  #接收人 用；分隔
  attr_accessor       :sendees
  validates_presence_of  :sendee,:sender
  #接收人 用；分隔
  def self.save_all(msg)
    self.transaction do
      msg.sendees.split(";").uniq.each do |sendee|
        new_msg = msg.clone
        sendee_user = User.find_by_id(sendee.index("(") ? sendee[sendee.index("(")+1,sendee.index(")")] : 0  )
        new_msg.sendee = sendee_user
        if !sendee_user || !new_msg.save
          msg.errors.add('收件人',(sendee) +' 不存在！')
          raise ActiveRecord::Rollback
          return false
        end
      end
    end
  end

  def self.per_page
    20
  end

  #是否可以回复
  def can_response?
    ! (sendee_stop ||  sender_stop)
  end
  #读消息
  def read_msg(user)
    if (!is_check) &&  user.ids.include?(sendee_id)
      update_attribute("is_check", true)
    end
    msg_responses.find(:all,
      :conditions=>["sender_id not in (?) and is_check=?",user.ids,false]).each { |res| res.update_attribute("is_check", true) }

  end
  #停止当前消息 如果对方已经停止可以删除
  #否则 停止 ，停止意味着 不能回复
  def stop_or_destroy(user)
    if user.ids.include?(sender_id)
      if sendee_stop
        destroy
      else
        update_attribute(:sender_stop, true)
      end
    else
      if sender_stop
        destroy
      else
        update_attribute(:sendee_stop, true)
      end
    end
  end
end
