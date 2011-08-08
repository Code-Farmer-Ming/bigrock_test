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
#    Msg.new_system_msg(:title=>"#{applicant_user.name}申请了，你发布的#{job.owner.name}的职位[#{job.title}]",:content=>'').send_to(job.create_user)
  end
end
