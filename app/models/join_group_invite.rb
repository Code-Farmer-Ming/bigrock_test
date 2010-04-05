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

#邀请参加小组
class JoinGroupInvite < Requisition
  

  #接受申请 变为普通成员
  def accept(user)
    self.applicant.add_to_member(user)
    self.destroy
  end


end
