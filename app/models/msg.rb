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
#  parent_id   :integer       default(0)
#

class Msg < ActiveRecord::Base
  
  validates_length_of :title, :within => 1..48


  #发送者
  belongs_to :sender,:class_name=>"User",:foreign_key=>"sender_id"
  #接收者
  belongs_to :sendee,:class_name=>"User",:foreign_key=>"sendee_id"

  belongs_to :parent,:foreign_key=>"parent_id",:class_name=>"Msg"

  #消息 的回复
  has_many :msg_responses ,:class_name=>"Msg",:foreign_key=>"parent_id",   :dependent => :destroy
 
  #未读的信息
  named_scope :unread,:conditions=>[:is_check=>false]

  #接收人 用 分隔
  attr_accessor       :sendees
  validates_presence_of  :sendee,:sender
  
  def before_validation_on_create 
    self.title = "回复 :" +parent.title if parent
  end
  
  def after_create
    if not is_online(self.sendee)
      MailerServer.deliver_get_new_msg(self)
    end
  end

    def who_is_online
    whos_online = Array.new()
    onlines = ActiveRecord::SessionStore::Session.find( :all, :conditions => ["updated_at >=?", Time.now() - 10.minutes ] )
    onlines.each do |online|
      id = Marshal.load( Base64.decode64( online.data ) )
      whos_online << id[:user]
    end
    whos_online
  end

  #是否在线
  def is_online(user)
    who_is_online.include?(user.id)
  end
  #接收人 用 分隔
  #TODO 这里有问题 需要好好考虑
  def self.save_all(msg)
    if not msg.sendees.blank?
      self.transaction do
        msg.sendees.split(" ").uniq.each do |sendee|
          new_msg = msg.clone
          sendee_id = sendee ? sendee : 0
          sendee_user = User.find(:first,:conditions=>["id=? or salt=?",sendee_id,sendee_id])
         
          if !sendee_user
            msg.errors.add('收件人',(sendee_user ? sendee_user.name : '') +' 不存在！')
            ActiveRecord::Rollback
            return false
          elsif   (sendee_user.id ==msg.sender_id)
            msg.errors.add('不需要给自己发信息哦！');
            return false
          elsif  !new_msg.send_to(sendee_user)
            msg.errors= new_msg.errors
            return false
          end
        end
      end
    else
      msg.errors.add('收件人  不能为空！')
      return false
    end
    true
  end
 

  #是否可以回复
  def can_response?
    ! (sendee_stop ||  sender_stop)
  end
  #读消息
  def read_msg(user)
    make_read unless !user.ids.include?(sendee_id)
    msg_responses.find(:all,
      :conditions=>["sender_id not in (?) and is_check=?",user.ids,false]).each { |res| res.make_read }
  end
  
  #标记为已读
  def make_read
    update_attribute("is_check", true) unless is_check
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
  #回复 消息
  def response(msg)
    if can_response?
      msg_responses << msg
    else
      !errors.add('回复信息',"不能回复，对方已经删除")
    end
  end
  #发送到用户
  def send_to(user)
    new_msg = self.clone
    new_msg.sendee = user
    new_msg.save!
  end
  #创建一个系统发送消息
  def self.new_system_msg(attributes={})
    attributes.delete(:sender_id)
    attributes.delete(:sender_stop)
    attributes = {:sender_id=>-1,:sender_stop=>true}.merge!(attributes)
    Msg.new(attributes)
  end
end
