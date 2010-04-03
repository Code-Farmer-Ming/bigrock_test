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
#  applicant_type :string(255)   
#

# To change this template, choose Tools | Templates
# and open the template in the editor.

class AddGroupApplication < Requisition
  
  def after_create
    MailerServer.deliver_join_group_invite(self)
  end
  #接受申请 变为普通成员
  def accept(user)
    self.applicant.add_to_member(user)
    self.destroy
  end
end
