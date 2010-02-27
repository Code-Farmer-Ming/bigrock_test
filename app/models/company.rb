# == Schema Information
#
# Table name: companies
#
#  id                   :integer       not null, primary key
#  name                 :string(255)   default("")
#  description          :text          
#  website              :string(255)   default("")
#  create_user_id       :integer       
#  created_at           :datetime      
#  updated_at           :datetime      
#  version              :integer       
#  salary_value         :integer       default(0)
#  condition_value      :integer       default(0)
#  company_judges_count :integer       default(0)
#  fax                  :string(255)   
#  phone                :string(255)   
#  last_edit_user_id    :integer       
#  address              :string(255)   default("")
#  industry_root_id     :integer       
#  industry_second_id   :integer       
#  industry_third_id    :integer       
#  industry_id          :integer       
#  company_type_id      :integer       
#  company_size_id      :integer       
#  state_id             :integer       
#  city_id              :integer       
#  topics_count         :integer       default(0), not null
#

class Company < ActiveRecord::Base
  acts_as_versioned   :if_changed => ["description","name","website","address"],:limit=>4
  #不记录 这些字段的变化
  self.non_versioned_columns << 'company_type_id'
  self.non_versioned_columns << 'industry_id'
  self.non_versioned_columns << 'company_size_id'
  self.non_versioned_columns << 'create_user_id'
  self.non_versioned_columns << 'last_edit_user_id'
  self.non_versioned_columns << 'salary_value'
  self.non_versioned_columns << 'condition_value'
  self.non_versioned_columns << 'company_judges_count'
  self.non_versioned_columns << 'fax'
  self.non_versioned_columns << 'phone'
  self.non_versioned_columns << 'industry_root_id'
  self.non_versioned_columns << 'industry_second_id'
  self.non_versioned_columns << 'industry_third_id'
  self.non_versioned_columns << 'state_id'
  self.non_versioned_columns << 'city_id'
  self.non_versioned_columns << 'topics_count'
  
  belongs_to :create_user ,:class_name=>"User",:foreign_key=>"create_user_id"
  
  belongs_to :last_edit_user ,:class_name=>"User",:foreign_key=>"last_edit_user_id"
  belongs_to :state
  belongs_to :city
   
  has_many :passes,:dependent=>:destroy
  has_many :judges,:class_name=>"CompanyJudge",:dependent=>:destroy,:order=>"created_at desc"
  #当前的员工
  has_many :current_employees ,
    :source=>:user,:through=>:passes,:conditions=>"passes.is_current=#{true}"
  #当前员工中 资料可信度高的
  has_many :higher_creditability_employees,
    :source=>:user,:through=>:passes,
    :conditions=>"passes.is_current=#{true} and ((passes.creditability_value/passes.judges_count)>=4)"
  #过去的员工
  has_many :pass_employees ,:source=>:user,:through=>:passes,:conditions=>"passes.is_current=#{false}"
  #所有的员工
  has_many :all_employees ,
    :source=>:user,:through=>:passes
  #相似的公司
  has_many :similar_tag_companis,:class_name=>"Company",
    :finder_sql=>'select * from (select id ,sum(tags) tag_count,count(1) same_tags
                                from (select e.taggable_id id ,e.user_tags_count tags from
                                      (select * from  taggings d where #{id}<>d.taggable_id and d.taggable_type=\'Company\' ) e
                                      join
                                      (select * from   taggings b where #{id}=b.taggable_id and b.taggable_type=\'Company\' ) f
                                     on e.tag_id=f.tag_id ) g
                                    group by id
                                    order by same_tags desc,tag_count desc) y join companies z on y.id=z.id ' do
    def find(*args)
      options = args.extract_options!
      sql = @finder_sql
 
      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end
  #动态信息
  has_many :log_items,:as=>:owner,:dependent => :destroy,:order=>"created_at desc"
  #新闻
  has_many :news ,:dependent => :destroy,:order=>"created_at desc"
  has_many :topics,:as=>:owner,:dependent=>:destroy,:order => 'top_level desc ,last_comment_datetime DESC'
  has_many :comments ,:through => :topics
  has_many :news_comments ,:through => :news
  #关注我的 用户
  has_many :follow_me_collection ,:class_name=>"Attention",:as=>:target,:dependent => :destroy
  has_many :follow_me_users,:through=>:follow_me_collection,:source=>:user
  
  #    same_industry_companies.collect{|company | if company }
  ## has_one
  #图标
  has_one :icon,:class_name=>"CompanyIcon",:foreign_key=>"master_id",:dependent=>:destroy


#  belongs_to :industry_root
#  belongs_to :industry_second
#  belongs_to :industry_third
  belongs_to :industry

  belongs_to :company_type
  belongs_to :company_size

  #named_scope
  #  named_scope :same_industry_companies ,:conditions => {:industry_id => '#{industry_id}'}
  #验证
  #唯一
  validates_uniqueness_of     :name
  #不为空
  validates_presence_of       :name

  #相似的公司 先根据 标签的相似度查找 如果不存在 就从相同 行业里查找
  def related_companies(limit=3)
    if limit==-1
      arr =  similar_tag_companis.find(:all)
      arr = Company.find_all_by_industry_id("#{industry_id}",:conditions=>"id<>#{id}") if arr.size<1
    else
      arr = similar_tag_companis.find(:all,:limit=>limit)
      arr =  Company.find_all_by_industry_id("#{industry_id}",:conditions=>"id<>#{id}",:limit=>limit) if arr.size<1
    end
    arr
  end
 
  #图标 文件路径
  def icon_file_path(thumbnail=nil)
    if (thumbnail)
      icon ? (icon.public_filename(thumbnail)) : "default_company_thumb.png"
    else
      icon ? (icon.public_filename) : "default_company.png"
    end
  end
  #公司 待遇 评论的人数
  def salary_judge_count(star=0)
    self.judges.find(:all,:conditions=>"salary_value=#{star} or (salary_value>#{star} and #{star}=0)").size
  end

  #公司 环境 评论的人数
  def condition_judge_count(star=0)
    self.judges.find(:all,:conditions=>"condition_value=#{star} or (condition_value>#{star} and #{star}=0)").size
  end
  #是不是本公司的员工
  def current_employee?(user)
    current_employees.exists?(user)
  end
  
  #TODO 这里可能会有点问题 当Vsersion.pass的的时候
  class Version
    belongs_to :edit_user, :class_name => '::User', :foreign_key => 'last_edit_user'
    #按 列 查找版本内容
    def self.find_version_by_column(column)
      self.find :all,:conditions=>"#{column}<>\"\"",:select=>"distinct #{column}"
    end
  end
end
