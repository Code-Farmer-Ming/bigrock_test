# == Schema Information
#
# Table name: passes
#
#  id                  :integer       not null, primary key
#  company_id          :integer       
#  resume_id           :integer       
#  user_id             :integer       
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
#  job_title_id        :integer       default(0)
#

class Pass < ActiveRecord::Base
  validates_uniqueness_of :company_id, :scope => [:resume_id,:user_id ]
  #记录修改 资料
  acts_as_logger :log_action=>["create","destroy"],:owner_attribute=>"user",:log_type=>"resume",:logable=>"company"
  #记录公司 加入人
  acts_as_logger :log_action=>["create","destroy"],:owner_attribute=>"company",:log_type=>"join_company",:logable=>"user"
  attr_accessor :title
  
  belongs_to :resume
  belongs_to :company
  belongs_to :user ,:class_name=>"User",:foreign_key => "user_id"

  belongs_to :job_title
  
  has_many :work_items,:dependent=>:destroy ,:order=>"begin_date desc"
  #对这段经历的评价
  has_many :judges, :dependent=>:destroy ,:order=>"created_at desc"

  #所有的同一个公司 并且工作日期有交集 经历
  has_many :record_passes,:class_name=>"Pass",:through=>:all_colleagues,:source => :colleague_pass

  #所有的同一个公司 并且工作日期有交集的记录
  has_many :all_colleagues,:class_name=>"Colleague",:dependent=>:destroy,:foreign_key => "my_pass_id"
  #所有的同一个公司 并且工作日期有交集的人
  has_many :all_colleague_users,:class_name=>"User",:through=>:all_colleagues,:source => :colleague_user
  #未确认的同事
  has_many :undetermined_colleagues,:class_name=>"Colleague", :dependent=>:destroy,:foreign_key => "my_pass_id",:conditions=>{:state=>Colleague::STATES[0]}
  has_many :undetermined_colleague_users,:class_name=>"User",:through=>:undetermined_colleagues,:source => :colleague_user

  #已经确认的同事
  has_many :colleagues, :dependent=>:destroy,:foreign_key => "my_pass_id",:conditions=>{:state=>Colleague::STATES[1]}
  has_many :colleague_users,:class_name=>"User",:through=>:colleagues,:source => :colleague_user

  #对自己仍未评价
  has_many :not_judged_me_colleagues,:class_name=>"Colleague", :dependent=>:destroy,:foreign_key => "my_pass_id",:conditions =>{:is_judge=>false,:state=>Colleague::STATES[1]}
  #对自己仍未评价的同事
  has_many :not_judged_me_colleague_users,:class_name=>"User",:through=>:not_judged_me_colleagues,:source => :colleague_user

  #对自己已评价
  has_many :has_judge_me_colleagues,:class_name=>"Colleague", :dependent=>:destroy,:foreign_key => "my_pass_id",:conditions =>{:is_judge=>true,:state=>Colleague::STATES[1]}
  #对自己已评价的同事
  #  has_many :has_judged_me_colleague_users,:class_name=>"User",:through=>:has_judge_me_colleagues,:source => :colleague_user
  #给自己评价的信息
  has_many :judge_me_infos,:through=>:has_judge_me_colleagues,:source=>:judge

  #被他们当做同事
  #  has_many :them_colleagues,:class_name=>"Colleague", :dependent=>:destroy,:foreign_key => "colleague_pass_id"
  #  has_many :them_colleague_users,:class_name=>"User",:through=>:colleagues,:source => :them_colleagues

  #被他们当做同事 我还还未评价他们
  has_many :not_judge_them_colleagues,:class_name=>"Colleague", :dependent=>:destroy,:foreign_key => "colleague_pass_id",:conditions=>{:is_judge=>false,:state => Colleague::STATES[1]}
  has_many :not_judge_them_colleague_users,:through=>:not_judge_them_colleagues,:source=>:user,:uniq=>true

  #被他们当做同事 我已评价他们的
  has_many :has_judge_them_colleagues,:class_name=>"Colleague", :dependent=>:destroy,:foreign_key => "colleague_pass_id",:conditions=>{:is_judge=>true,:state => Colleague::STATES[1]}
  #  has_many :has_judge_them_colleague_users,:through=>:has_judge_them_colleagues,:source=>:user,:uniq=>true
  #我评价过的信息
  has_many :judged_infos,:through=>:has_judge_them_colleagues,:source=>:judge,:uniq=>true

  #按日期排序
  named_scope :date_desc_order,:order=>"iscurrent desc,begin_date  desc"
  #Pass删除时的 要清除该pass对应的 其他人和公司的评价
  def before_destroy
    clear_data()
  end

  def after_create
    user.my_follow_companies << company unless user.my_follow_companies.exists?(company)
  end

  def before_save
    if @title
      self.job_title = JobTitle.find_or_create_by_name_and_company_id(@title,self.company.id)
    end
  end
  


  def after_save
    if self.job_title_id_changed?
      JobTitle.destroy_all(:id=>self.job_title_id_was)
    end
    #pass 的开始、结束日期改变的时候 更新 同事列表信息
    if begin_date_changed? || end_date_changed?
      same_passes =  real_get_same_company_pass
      add_list =  same_passes - record_passes
      
      new_colleague_notice =  Msg.new_system_msg(:title=>"有新同事加入了",:content=>"<a href='/users/#{user.id}'>#{user.name}</a>新加入了<a href='/companies/#{company.id}'>#{company.name}</a>也许你们认识快去看看吧。")
      #新可能的同事
      add_list.each do |add_pass|
        colleagues << Colleague.new(:colleague_pass=>add_pass,:user=>user,:colleague_user=>add_pass.user,:company=>company)
        add_pass.all_colleagues << Colleague.new(:colleague_pass=>self,:user=>add_pass.user,:colleague_user=>user,:company=>company)
        new_colleague_notice.send_to(add_pass.user)
      end
      destroy_list =  record_passes - same_passes
      #需要移除的同事
      destroy_list.each do |destroy_pass|
        all_colleagues.first(:conditions=>{:colleague_pass_id=>destroy_pass.id}).destroy
        destroy_pass.all_colleagues.first(:conditions=>{:colleague_pass_id=>self.id}).destroy
      end
    end
  end
  #  实时 获取 同一时间 工作的经历
  def real_get_same_company_pass
    Pass.find_by_sql("select a.* from passes a  where (begin_date between '#{begin_date.to_date}' and '#{end_date.to_date}'
        or end_date between '#{begin_date.to_date}' and '#{end_date.to_date}'
        or '#{begin_date.to_date}' between begin_date and end_date
        or '#{end_date.to_date}' between begin_date and end_date
        or ('#{end_date.to_date}'>=begin_date and is_current)
        or (is_current=#{is_current} and is_current)
        or ('#{begin_date.to_date}' <=end_date and #{is_current})
      )  and company_id=#{company_id} and a.id<>#{id}")
  end
  
  #清除相关 pass产生评价等 数据
  def clear_data
    #取消对此公司的关注
    #    user.remove_attention(company)
    #取消 对公司的评价
    CompanyJudge.destroy_all(:company_id=>company,:user_id=>user)
  end
  
  def title
    job_title &&  job_title.name
  end
  #column_name 如下值
  #ability
  #eq_value
  #creditability
  def judge_count_by_star(column_name,star=0)
    self.judges.judge_star(column_name,star).count
  end

  #TODO：速度可以优化 使用
  # creditability_value :integer       default(0)
  #  ability_value       :integer       default(0)
  #  eq_value            :integer       default(0)
  #judges_count
  def average_judge(column_name)
    self.judges.average(column_name).to_f.round(1)
  end

  #用户 是否有可见的权限
  def can_visibility?(user)
    self.user.setting.can_visibility?(:pass_visibility,user)
  end
  #是否有 工作业绩
  def has_work_items?
    self.work_items.size>0
  end

  protected
  #有效性检查 不是开始日期小于结束日期提示
  def validate
    if !is_current && begin_date.to_date>end_date.to_date
      errors.add("begin_date", "结束日期不能早于结开始期")
    end
  end


end
