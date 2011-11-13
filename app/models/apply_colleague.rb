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
#  applicant_type :string(255)   default(""), not null
#

# To change this template, choose Tools | Templates
# and open the template in the editor.
#成為同上的申請
class ApplyColleague < Requisition
  #  def after_create
  #    MailerServer.deliver_join_group_invite(self)
  #  end

  #接受申请 
  def accept()
    #好友解除
    if (self.applicant.friend_users.exists?(self.respondent))
      self.applicant.cancel_friend(self.respondent)
    end
    #好友申请去除
    if (self.applicant.my_add_friend_application_users(self.respondent))
      self.applicant.my_add_friend_application_users.delete(self.respondent)
    end
    if (self.respondent.my_add_friend_application_users(self.applicant))
      self.respondent.my_add_friend_application_users.delete(self.applicant)
    end
    
    self.applicant.need_comfire_colleagues.find_all_by_colleague_id(self.respondent.id).each() do |colleague|
      colleague.confirm
    end
    self.respondent.need_comfire_colleagues.find_all_by_colleague_id(self.applicant.id).each() do |colleague|
      colleague.confirm
    end
 
    self.destroy
    accept_colleague_notify(respondent,applicant)
  end

  private
  #加入小组申请通过时 发送站内信息
  def accept_colleague_notify(respondent, to_user)
    msg = Msg.new_system_msg(:title=>"您申请#{respondent.name}为同事的请求已经通过",:content=>"确认您为同事。")
    msg.send_to(to_user)
  end
end