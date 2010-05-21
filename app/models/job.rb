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
#

class Job < ActiveRecord::Base
  JOB_TYPES = ["全职", "兼职"]
  #字段验证
  validates_presence_of :title,:job_description,:company_id,:create_user_id
  
  belongs_to :company,:counter_cache => true
  belongs_to :create_user,:class_name=>"User",:foreign_key =>"create_user_id"
  belongs_to :state
  belongs_to :city
  delegate :name,:to=>:state, :prefix => true
  delegate :name,:to=>:city, :prefix => true

  named_scope :limit,lambda { |size| { :limit => size } }
  named_scope :since,lambda { |day| { :conditions =>["(created_at>? or ?=0) ",day.to_i.days.ago,day]  } }

  def self.types
    JOB_TYPES.enum_for(:each_with_index).map { |type, index| [type, index] }
  end
  
  def type
    JOB_TYPES[type_id.to_i]
  end
  #工作地点
  def site
    "#{ state_name} #{city_name}"
  end

  def other_jobs(limit=6)
    company.jobs.all(:conditions=>"id<>#{id}",:limit=>limit)
  end
end
