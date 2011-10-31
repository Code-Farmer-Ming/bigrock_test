# == Schema Information
#
# Table name: requisitions
#
#  id             :integer       not null, primary key
#  applicant_id   :integer       
#  respondent_id  :integer       
#  type           :string(255)   
#  memo           :string(255)   
#  created_at     :datetime      
#  updated_at     :datetime      
#  applicant_type :string(255)   not null
#

class AddFriendApplication < Requisition

   def after_create
    MailerServer.deliver_apply_friend_request(self)
  end
  
  #接收 添加好友的申请
  #自己变为user的好友
  def accept(user)
    self.applicant.add_friend(user)
    self.destroy
  end
  
end