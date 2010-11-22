# == Schema Information
#
# Table name: resumes
#
#  id               :integer       not null, primary key
#  name             :string(255)   
#  type_name        :string(18)    
#  user_id          :integer       
#  user_name        :string(18)    
#  birthday         :date          
#  sex              :boolean       
#  address          :string(255)   
#  mobile           :string(255)   
#  telephone        :string(255)   
#  phone3           :string(255)   
#  phone4           :string(255)   
#  blog_website     :string(255)   
#  personal_website :string(255)   
#  website3         :string(255)   
#  website4         :string(255)   
#  self_description :text          
#  goal             :string(255)   
#  interests        :string(255)   
#  qq               :string(255)   
#  msn              :string(255)   
#  city             :string(255)   
#  industry         :string(255)   
#  is_current       :boolean       
#  created_at       :datetime      
#  updated_at       :datetime      
#  city_id          :integer       
#  state_id         :integer       
#

class Resume < ActiveRecord::Base
  #简历类型
  RESUME_TYPES=["中文","英文"]
  #  validates_format_of :blog_website, :with =>  /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(([0-9]{1,5})?\/.*)?$)/ix

  belongs_to :state
  belongs_to :city
  belongs_to :user,:class_name=> "User",:foreign_key =>"user_id"
  
  has_many :passes,:dependent=>:destroy ,:order=>"begin_date desc,is_current desc"
  has_many :current_passes,:class_name=>"Pass",:conditions=>{:is_current=>true}
  #经历过的公司  包含当前公司的
  has_many :pass_companies ,:through=>:passes,:source=>:company
  has_many :current_companies ,:through=>:current_passes,:source=>:company
  
  has_many :educations,:dependent=>:destroy,:order=>"begin_date desc"
  has_many :specialities,:dependent=>:destroy
  has_many :skills,:through=>:specialities,:source=>:skill
  #获取 某个 工作经历 中的同事
  has_many :yokemates, :class_name => "User",
    :finder_sql => "select  distinct c.* from passes a join passes b  join users c
on c.id=b.user_id and a.company_id=b.company_id   and
(a.begin_date between b.begin_date and b.end_date or
a.end_date between b.begin_date and b.end_date or
b.begin_date between a.begin_date and a.end_date or
b.end_date between a.begin_date and a.end_date)
and a.resume_id <>b.resume_id where a.resume_id=\#{id}"  do
    def all(*args)
      options = args.extract_options!
      sql = @finder_sql
      sql += " and #{sanitize_sql options[:conditions]}"  if options[:conditions]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
    def find(*args)
      options = args.extract_options!
      sql = @finder_sql
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
    def exists?(*args)
      options = args.extract_options!

      options[:conditions] =expand_id_conditions(args)
      options[:limit] =1
      sql = @finder_sql
      sql += sanitize_sql " and  #{options[:conditions]}" if options[:conditions]
      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql).size >0
    end
  end
   def skill_list 
    skills.reload
    skills.to_s
  end

  #简历是否有同事
  def has_yokemates?
    self.yokemates.size >0
  end




end
