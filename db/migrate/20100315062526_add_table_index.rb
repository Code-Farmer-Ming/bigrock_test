class AddTableIndex < ActiveRecord::Migration
  def self.up
    add_index :votes,[:owner_id,:owner_type,:user_id], :unique => true
    add_index :states,:name
    add_index :specialities,[:resume_id,:skill_id],:unique => true
    add_index :recommends,[:user_id,:recommendable_type,:recommendable_id],:unique => true,:name=>:index_recommendable_user
    add_index :passes,[:company_id,:resume_id ,:user_id],:unique => true
    add_index :members,[:group_id,:user_id],:unique => true
    add_index :judges,[:pass_id,:user_id,:judger_id],:unique => true
    add_index :industries,:name
    add_index :groups,:name
#    add_index :friends,[:user_id,:friend_id],:unique => true
    add_index :educations,[:resume_id,:school_id],:unique => true
    add_index :company_types,:name
    add_index :company_sizes,:name
    add_index :company_judges,[:company_id,:user_id],:unique => true
    add_index :companies,:name
    add_index :cities,:name
    add_index :attentions,[:user_id,:target_id,:target_type],:unique => true
    add_index :requisitions,[:applicant_id,:respondent_id,:applicant_type,:type],:unique => true,:name=>:index_requisition_applicant
  end

  def self.down
  end
end
