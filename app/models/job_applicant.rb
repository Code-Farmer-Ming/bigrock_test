# == Schema Information
#
# Table name: job_applicants
#
#  id                      :integer       not null, primary key
#  job_id                  :integer       not null
#  applicant_id            :integer       not null
#  recommend_id            :integer       
#  memo                    :string(255)   
#  created_at              :datetime      
#  updated_at              :datetime      
#  is_deleted_by_published :boolean       
#  is_deleted_by_applicant :boolean       
#  is_read                 :boolean       
#

class JobApplicant < ActiveRecord::Base
  belongs_to :job,:counter_cache=>"applicants_count"
  #申请者
  belongs_to :applicant_user,:class_name=>"User",:foreign_key=>"applicant_id"
  #推荐者
  belongs_to :recommend_user,:class_name=>"User",:foreign_key=>"recommend_id"

  #申请者 用 ' ' 分隔
  attr_accessor :applicant_user_ids
  #尝试去删除 申请记录，申请者和工作发布者，删除记录的时候只是先将记录设置为不可见，
  #只有双方都确定删除记录才真的删除
  def try_destroy(user)
    if applicant_user==user
      self.is_deleted_by_applicant = true
    end
    if job.create_user==user
      self.is_deleted_by_published = true
    end
    if self.is_deleted_by_applicant && self.is_deleted_by_published
      destroy
    else
      save
    end
  end
  
  def after_create
    Msg.new_system_msg(:title=>"#{applicant_user.name}申请了，你发布的#{job.owner.name}的职位[#{job.title}]",:content=>'').send_to(job.create_user)
    if recommend_user
      Msg.new_system_msg(:title=>"#{recommend_user.name} 将你举荐到 #{job.owner.name}的职位[#{job.title}]",:content=>'').send_to(applicant_user)
    end
  end
  
  #读申请
  def read
    unless is_read
      update_attributes(:is_read=>true)
      Msg.new_system_msg(:title=>"发布者已读您申请的:#{job.owner.name}的职位[#{job.title}]",:content=>'').send_to(applicant_user)
    end
  end

end
