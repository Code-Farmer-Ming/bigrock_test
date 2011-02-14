# == Schema Information
#
# Table name: jobs
#
#  id                :integer       not null, primary key
#  title             :string(255)   not null
#  type_id           :string(255)   not null
#  job_description   :text          default(""), not null
#  skill_description :text          
#  state_id          :integer       not null
#  city_id           :integer       not null
#  job_title_id      :integer       
#  end_at            :datetime      not null
#  create_user_id    :integer       
#  created_at        :datetime      
#  updated_at        :datetime      
#  company_id        :integer       
#  view_count        :integer       default(0)
#  applicants_count  :integer       default(0)
#  comments_count    :integer       default(0)
#  skill_text        :string(255)   
#

# == Schema Information
#
# Table name: jobs
#
#  id                :integer       not null, primary key
#  title             :string(255)   not null
#  type_id           :string(255)   not null
#  job_description   :text          default(""), not null
#  skill_description :text          
#  state_id          :integer       not null
#  city_id           :integer       not null
#  job_title_id      :integer       
#  end_at            :datetime      not null
#  create_user_id    :integer       
#  created_at        :datetime      
#  updated_at        :datetime      
#  company_id        :integer       
#  view_count        :integer       default(0)
#  applicants_count  :integer       default(0)
#  comments_count    :integer       default(0)
#
require 'skill_tag_extensions'
class Job < ActiveRecord::Base
  JOB_TYPES = ["全职", "兼职"]
  #字段验证
  validates_presence_of :title,:job_description,:company_id,:create_user_id
  #发布职位
  acts_as_logger :log_action=>["create"],:owner_attribute=>"create_user",:log_type=>"post_job"
  acts_as_logger :log_action=>["create"],:owner_attribute=>"owner",:log_type=>"user_post_job"
    
  belongs_to :owner,:foreign_key =>"company_id",:class_name=>"Company",:counter_cache => true
  belongs_to :create_user,:class_name=>"User",:foreign_key =>"create_user_id"
  belongs_to :state
  belongs_to :city

  #被动 作为 消息记录的内容
  has_many :logable_log_items,:class_name=>"LogItem",:as=>:logable,:dependent => :destroy,:order=>"created_at desc"
  has_many :comments ,:as=>:commentable,:dependent=>:destroy
  has_many :applicants,:class_name=>"JobApplicant",:dependent=>:destroy
    
  delegate :name,:to=>:state, :prefix => true
  delegate :name,:to=>:city, :prefix => true

  named_scope :limit,lambda { |size| { :limit => size } }
  named_scope :order,lambda { |order| { :order => order } }
  named_scope :since,lambda { |day| { :conditions =>["(jobs.created_at>? or ?=0) ",day.to_i.days.ago,day.to_i]  } }

  def self.types
    JOB_TYPES.enum_for(:each_with_index).map { |type, index| [type, index] }
  end
  
  def type
    JOB_TYPES[type_id.to_i]
  end

  def other_jobs(limit=6)
    owner.jobs.all(:conditions=>"id<>#{id}",:limit=>limit)
  end

  def add_comment(comment)
    comments << comment
  end

  def after_save
    skill_with skill_text if skill_text
  end
  
  #申请职位
  def apply_job(job_applicant)
    if job_applicant.applicant_user_ids
      unless job_applicant.applicant_user_ids.blank?
        job_applicant.applicant_user_ids.split(" ").uniq.each do |user_id|
          new_applicant = job_applicant.clone
          new_applicant.applicant_id = user_id
          applicants << new_applicant
        end
      else
        !errors.add '推荐好友','不能为空'
      end
    else
      applicants << job_applicant
    end
  end

  #相关的职位 根据申请了 这个职位又申请别的职位，按共同申请的数量 排序
  has_many :related_jobs,:class_name=>"Job",
    :finder_sql=>'select a.* ,count(*) from job_applicants x
                      join job_applicants y  on  x.applicant_id=y.applicant_id
                      join jobs a on a.id=x.job_id
                      where y.job_id=#{id} and x.job_id<>#{id}
                      group by x.job_id
                      order by count(*) desc ' do
    def all(*args)
      options = args.extract_options!
      sql = @finder_sql
      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end
  #根据标签 相似的职位
  has_many :similar_jobs,:class_name=>"Job",
    :finder_sql=>'select * from (select id ,count(1) same_tags
                                from (select e.taggable_id id from
                                      (select * from  skill_taggings d where #{id}<>d.taggable_id and d.taggable_type=\'Job\' ) e
                                      join
                                      (select * from skill_taggings b where #{id}=b.taggable_id and b.taggable_type=\'Job\' ) f
                                     on e.skill_id=f.skill_id ) g
                                    group by id
                                    order by same_tags desc) y join need_jobs z on y.id=z.id ' do

    def find(*args)
      options = args.extract_options!
      sql = @finder_sql

      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end
 
end
