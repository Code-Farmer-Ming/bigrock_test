#同事
class Colleague < ActiveRecord::Base
  validates_uniqueness_of :user_id, :scope =>:colleague_id,:message =>"已经是同事啦"
  belongs_to :user,:class_name=>"User",:foreign_key=>"user_id"
  belongs_to :colleague,:class_name=>"User",:foreign_key=>"colleague_id"
  acts_as_logger :log_action=>["create","destroy"],:owner_attribute=>"user",:logable=>"colleague"

  def after_create
    msg= Msg.new_system_msg(:title=>"系统提示：#{user.name}已经把你当做同事",:content=>"#{user.name}已经加你为好友,去看看吧。")
    msg.send_to(colleague)
  end
end
