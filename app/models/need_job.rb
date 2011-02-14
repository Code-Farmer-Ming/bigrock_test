# == Schema Information
#
# Table name: need_jobs
#
#  id          :integer       not null, primary key
#  title       :string(255)   
#  description :string(255)   
#  state_id    :integer       
#  city_id     :integer       
#  poster_id   :integer       
#  created_at  :datetime      
#  updated_at  :datetime      
#  type_id     :integer       default(0), not null
#  skill_text  :string(255)   
#  view_count  :integer       default(0)
#

# == Schema Information
#
# Table name: need_jobs
#
#  id          :integer       not null, primary key
#  title       :string(255)   
#  description :string(255)   
#  state_id    :integer       
#  city_id     :integer       
#  poster_id   :integer       
#  created_at  :datetime      
#  updated_at  :datetime      
#
require 'skill_tag_extensions'

class NeedJob < ActiveRecord::Base
  
  acts_as_logger :log_action=>["create"],:owner_attribute=>"poster",:log_type=>"post_need_job"
  #发布者
  belongs_to :poster ,:class_name=>"User",:foreign_key=>"poster_id"
  belongs_to :state
  belongs_to :city 
  named_scope :limit,lambda { |size| { :limit => size } }
  named_scope :order,lambda { |order| { :order => order } }
  named_scope :since,lambda { |day| { :conditions =>["(created_at>? or ?=0) ",day.to_i.days.ago,day.to_i]  } }

  delegate :name,:to=>:state, :prefix => true ,:allow_nil=>true
  delegate :name,:to=>:city, :prefix => true,:allow_nil=>true

  #被动 作为 消息记录的内容
  has_many :logable_logs,:class_name=>"LogItem",:as=>:logable,:dependent => :destroy,:order=>"created_at desc"


  #相似求职
  has_many :similar_need_jobs,:class_name=>"NeedJob",
    :finder_sql=>'select * from (select id ,count(1) same_tags
                                from (select e.taggable_id id from
                                      (select * from  skill_taggings d where #{id}<>d.taggable_id and d.taggable_type=\'NeedJob\' ) e
                                      join
                                      (select * from skill_taggings b where #{id}=b.taggable_id and b.taggable_type=\'NeedJob\' ) f
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
  
  def after_save
    skill_with skill_text if skill_text
  end
 
  
  #工作类型 全职兼职
  def type
    Job::JOB_TYPES[type_id]
  end
  
 
end
