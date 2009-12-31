# == Schema Information
#
# Table name: passes
#
#  id                  :integer       not null, primary key
#  company_id          :integer       
#  resume_id           :integer       
#  user_id             :integer       
#  title               :string(255)   
#  department          :string(255)   
#  begin_date          :date          
#  end_date            :date          
#  work_description    :text          
#  is_current          :boolean       
#  creditability_value :integer       default(0)
#  ability_value       :integer       default(0)
#  eq_value            :integer       default(0)
#  created_at          :datetime      
#  updated_at          :datetime      
#  judges_count        :integer       default(0)
#

class Pass < ActiveRecord::Base
  #记录修改 资料
  acts_as_logger :log_action=>["create","destroy"],:owner_attribute=>"user",:log_type=>"resume",:logable=>"company"
  #记录公司 加入人
  acts_as_logger :log_action=>["create"],:owner_attribute=>"company",:log_type=>"join_company",:logable=>"user"
  
  belongs_to :resume
  belongs_to :company
  belongs_to :user ,:class_name=>"User",:foreign_key => "user_id"

  
  #获取 某个 工作经历 中的同事
  has_many :yokemates, :class_name => "User",
    :finder_sql => "select b.* from passes a join users b on a.user_id=b.id where (begin_date between '\#{begin_date}' and '\#{end_date}'
        or end_date between '\#{begin_date}' and '\#{end_date}'
        or '\#{begin_date}' between begin_date and end_date
        or '\#{end_date}' between begin_date and end_date) and company_id=\#{company_id} and a.id<>\#{id}"  do
    def find(*args)
      options = args.extract_options!
      sql = @finder_sql
      sql += sanitize_sql " and #{options[:conditions]}" if options[:conditions]
      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
    #    def exists?(*args)
    #      sql = @finder_sql
    #      find_by_sql(sql)
    #    end
  end
 
  #获取所有可以评价的同事的
  has_many :available_yokemates, :class_name => "User",
    :finder_sql => "select b.* from passes a join users b on a.user_id=b.id
        where (begin_date between '\#{begin_date}' and '\#{end_date}'
        or end_date between '\#{begin_date}' and '\#{end_date}'
        or '\#{begin_date}' between begin_date and end_date
        or '\#{end_date}' between begin_date and end_date) and company_id=\#{company_id} and a.id<>\#{id} and b.id not in (select judger_id from judges d where d.user_id=\#{user_id} )",
    :counter_sql=>"select count(*) count_all from passes a join users b on a.user_id=b.id
        where (begin_date between '\#{begin_date}' and '\#{end_date}'
        or end_date between '\#{begin_date}' and '\#{end_date}'
        or '\#{begin_date}' between begin_date and end_date
        or '\#{end_date}' between begin_date and end_date) and company_id=\#{company_id} and a.id<>\#{id} and b.id not in (select judger_id from judges d where d.user_id=\#{user_id} )"
  
  has_many :work_items,:dependent=>:destroy ,:order=>"begin_date desc"
  has_many :judges, :dependent=>:destroy ,:order=>"created_at desc"

  has_many :content_text_judges,:class_name => "Judge", :dependent=>:destroy,:autosave=>true,:conditions => "description<>\"\""
  has_many :ability_judges,:class_name => "Judge", :dependent=>:destroy,:autosave=>true,:conditions => "ability_value>0"
  has_many :eq_judges,:class_name => "Judge", :dependent=>:destroy,:autosave=>true,:conditions => "eq_value>0"
  has_many :creditability_judges,:class_name => "Judge", :dependent=>:destroy,:autosave=>true,:conditions => "creditability_value>0"
  #Pass删除时的 要清除该pass对应的 其他人和公司的评价
  def before_destroy
    clear_data()
  end

  def before_create
    if  !user.my_follow_companies.exists?(company)
      user.my_follow_companies << company
    end
  end
  
  def after_save
    if self.company_id_changed? 
 
      after_destroy()
    end
  end
  #清除相关 pass产生评价等 数据
  def clear_data
    #取消对公司同事的评价
    user.judged.all.each{ |object| object.destroy if (object.pass.company==company) }
    #取消对此公司的关注
    user.targets.delete(company)
    #取消 对公司的评价
    CompanyJudge.destroy_all(:company_id=>company,:user_id=>user )
  end
  #ability
  def ability_judge_count(star=0)
    self.judges.find(:all,:conditions=>"ability_value=#{star} or (ability_value>#{star} and #{star}=0)").size
  end
  #eq_value
  def eq_judge_count(star=0)
    self.judges.find(:all,:conditions=>"eq_value=#{star} or (eq_value>#{star} and #{star}=0)").size
  end
  #creditability
  def creditability_judge_count(star=0)
    self.judges.find(:all,:conditions=>"creditability_value=#{star} or (creditability_value>#{star} and #{star}=0)").size
  end

  def average_judge(cloum_name)
    self.judges.average(cloum_name)
  end
  #是否 同事 可以评价
  def yokemate?(user)
    Pass.find_all_by_company_id(self.company_id,
      :conditions=>" (begin_date between '#{begin_date}' and '#{end_date}'
      or end_date between '#{begin_date}' and '#{end_date}'
      or '#{begin_date}' between begin_date and end_date
      or '#{end_date}' between begin_date and end_date) and id<>#{id} and user_id=#{user ? user.id : -1}").size > 0

  end

end
