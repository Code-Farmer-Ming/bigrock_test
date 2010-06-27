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

end
