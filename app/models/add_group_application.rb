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

# To change this template, choose Tools | Templates
# and open the template in the editor.

class AddGroupApplication < Requisition
#  def after_create
#    MailerServer.deliver_join_group_invite(self)
#  end

  #接受申请 变为普通成员
  def accept(user)
    self.applicant.add_to_member(user)
    self.destroy
    accept_join_group_notify(user)
  end
  
  private
  #加入小组申请通过时 发送站内信息
  def accept_join_group_notify(user)
    msg = Msg.new_system_msg(:title=>"加入[#{name}]小组的申请通过",:content=>"已经成为小组成员,去看看吧")
    msg.send_to(user)
  end
end
