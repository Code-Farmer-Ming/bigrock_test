# == Schema Information
#
# Table name: users
#
#  id         :integer       not null, primary key
#  nick_name  :string(255)   default("马甲"), not null
#  email      :string(255)   not null
#  password   :string(255)   not null
#  title      :string(255)   default("")
#  is_active  :boolean       
#  created_at :datetime      
#  updated_at :datetime      
#  parent_id  :integer       default(0), not null
#  state      :string(12)    default("freedom")
#  salt       :string(255)   not null
#


class User< ActiveRecord::Base
  #状态
  STATE_TYPES= {:working=>"我工作很好",:freedom=>"我需要工作",:student=>"我还是学生"}
  
  acts_as_logger :log_action=>["create"],:owner_attribute=>:self,:log_type=>"register_account",:can_log=>:"!is_alias?"
  #字段验证
  validates_presence_of       :email,:password

  validates_format_of :email, :with => /\A([^@\s]+)@((?:[-a-z0-9]+\.)+[a-z]{2,})\Z/i, :on => :create

 
  validates_uniqueness_of     :email, :message=>"邮件地址不能重复"
  attr_accessor                 :text_password
  validates_confirmation_of   :text_password,  :message=>"两次不同"
  attr_accessor                 :text_password_confirmation
  validates_length_of :nick_name, :within => 2..10
  #我的简历
  has_many :resumes,:foreign_key=>"user_id",:dependent=>:destroy


  #别人对自己的评价
  has_many :judges,:foreign_key=>"user_id",:dependent=>:destroy
  #自己对别人的评价
  has_many :judged,:class_name=>"Judge",:foreign_key=>"judger_id",:dependent=>:destroy
  #对所在公司的评价
  has_many :judged_companies,:class_name=>"CompanyJudge",:foreign_key=>"user_id",:dependent=>:destroy

  #我的好友
  has_many :friends,:foreign_key=>"user_id",:dependent=>:destroy
  has_many :friend_users,:through=>:friends,:source=>:friend
  has_many :created_news,:class_name=>"Piecenews",:foreign_key=>"create_user_id",:dependent=>:destroy
  #被谁加为好友
  has_many :friendeds,:class_name=>"Friend",:foreign_key=>"friend_id",:dependent=>:destroy

  #  #添加好友 申请
  has_many :add_friend_applications ,:foreign_key=>"respondent_id",
    :dependent=>:destroy,:class_name=>"AddFriendApplication",:source=>:applicant
  # 小组邀请
  has_many :join_group_invites ,:foreign_key=>"respondent_id",
    :dependent=>:destroy,:class_name=>"JoinGroupInvite",:source=>:applicant
  #发起的消息
  has_many :send_msgs,:class_name=>"Msg",
    :finder_sql=>'SELECT * FROM `msgs` WHERE ' +
    'parent_id=0 and sender_stop=#{false} and sender_id in (#{ids.join(\',\')})  order by created_at desc' do
    def find(*args)
      options = args.extract_options!
      sql = @finder_sql
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end
  #接收的消息
  has_many :receive_msgs,:class_name=>"Msg",
    :finder_sql=>'SELECT * FROM `msgs` WHERE parent_id=0 and sendee_stop=#{false} and sendee_id in (#{ids.join(\',\')})  order by created_at desc' do
    def find(*args)
      options = args.extract_options!
      sql = @finder_sql
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end
  #所有的消息 接收和发送
  has_many  :all_msgs,:class_name=>"Msg",:finder_sql =>
    'SELECT DISTINCT msgs.* ' +
    'FROM msgs ' +
    'WHERE msgs.sender_id in (#{ids.join(\',\')}) or msgs.sendee_id in (#{ids.join(\',\')})',
    :dependent => :destroy

  #  未读的消息
  has_many  :unread_msgs,:class_name=>"Msg",:finder_sql =>
    'SELECT DISTINCT a.* ' +
    'FROM msgs a left join msgs b on a.id=b.parent_id ' +
    'WHERE a.parent_id=0 and a.sendee_id in (#{ids.join(\',\')}) and a.sendee_stop=false and (a.is_check=#{false} or  b.is_check=#{false})'+
    "  order by a.created_at desc",
    :counter_sql=> 'select count(*) from (SELECT DISTINCT a.* ' +
    'FROM msgs a left join msgs b on a.id=b.parent_id ' +
    'WHERE  a.parent_id=0 and a.sendee_id in (#{ids.join(\',\')}) and a.sendee_stop=false and (a.is_check=#{false} or  b.is_check=#{false})) new_msgs' do
    def find(*args)
      options = args.extract_options!
      sql = @finder_sql
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end
  #标签
  has_many :user_tags,:foreign_key=>"user_id",:dependent => :destroy
  has_many :user_taggings,:through => :user_tags,:source=>:tagging

  #我的动态信息
  has_many :log_items,:as=>:owner,:class_name=>"LogItem",:dependent => :delete_all,:order=>"created_at desc"
  #被记录的 动态信息包含我的信息
  has_many :loged_items,:as=>:logable,:class_name=>"LogItem",:dependent => :delete_all

  #  has_many :my_follow_collection,:class_name=>"Attention",:as=>:target
  #跟随关注我的用户
  has_many :follow_me_collection ,:class_name=>"Attention",:as=>:target,:dependent => :delete_all
  has_many :follow_me_users,:through=>:follow_me_collection,:source=>:user 
  #  has_many :my_follow,:through=>:my_follow_collection,:source=>:target
  #我跟随关注的用户或公司或其他
  has_many :my_follow_collection,:class_name=>"Attention",:foreign_key=>"user_id",:dependent => :delete_all
  has_many :my_follow_users,:through=>:my_follow_collection,:source=>:target,:source_type=>"User"
  has_many :my_follow_companies,:through=>:my_follow_collection,:source=>:target,:source_type=>"Company"
  #关注的目标 包括 用户或公司
  has_many_polymorphs :targets,
    :from => [:companies,:users],
    :through => :attentions,
    :foreign_key=>"user_id",
    :dependent => :destroy

  has_many :my_follow_log_items ,:class_name=>"LogItem",
    :finder_sql=>'select a.* from log_items a left join attentions b on a.owner_id=b.target_id and a.owner_type=b.target_type
  where b.user_id=#{id} ' do
    def find(*args)
      options = args.extract_options!
      sql = @finder_sql
      options[:order] ||= "created_at desc"
      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
    
    def find_all_by_owner_type(*args)
      options = args.extract_options!
      options[:order] ||= "created_at desc"
      sql = @finder_sql
      where_index = sql.index("where")
      if where_index >-1
        sql.insert(where_index+5,  " owner_type = '#{args[0]}' and " )
      end
      #      add_joins!(sql, options[:joins], scope)
      #      add_group!(sql, options[:group], options[:having], scope)
      #      add_order!(sql, options[:order], scope)
      #      add_limit!(sql, options, scope)
      #      add_lock!(sql, options, scope)
      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end

  #用户右上角 所说话
  has_many :my_languages,:foreign_key=>"user_id",:dependent=>:delete_all,:order=>"id desc"
  #用户的推荐
  has_many :recommends,:foreign_key=>"user_id",:dependent => :destroy

  has_many :members ,:foreign_key=>"user_id",:dependent => :destroy
  #参加的小组
  has_many :groups,:through => :members,:source=>:group,:order=>"members.created_at desc"
  #管理的小组
  has_many :manage_groups,:class_name=>"Group",
    :finder_sql => 'select groups.* from groups INNER JOIN  members on groups.id=members.group_id 
                  where user_id in (#{ids.join(\',\')})'+
    " and (members.type='#{Member::MEMBER_TYPES[0]}' or members.type='#{Member::MEMBER_TYPES[1]}')",
    :order=>"members.created_at desc" do
    def find(*args)
      options = args.extract_options!
      sql = @finder_sql
      sql += sanitize_sql " and #{options[:conditions]}" if options[:conditions]
      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end
  #创建的小组
  has_many :create_groups,:class_name=>"Group",:foreign_key => "create_user_id"
  #其他马甲身份参加的小组
  has_many :hidden_groups,:class_name=>"Group",
    :finder_sql => 'select groups.* from groups INNER JOIN  members on groups.id=members.group_id where user_id in (#{alias_ids.join(\',\')})',
    :order=>"members.created_at desc" do
    def find(*args)
      options = args.extract_options!
      sql = @finder_sql
 
      sql += sanitize_sql " and #{options[:conditions]}" if options[:conditions]
      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end
  #所有身份参与的小组 
  has_many :all_groups,:class_name=>"Group",
    :finder_sql => 'select groups.* from groups INNER JOIN  members on groups.id=members.group_id where user_id in (#{ids.join(\',\')})',
    :order=>"members.created_at desc" do
    def find(*args)
      options = args.extract_options!
      sql = @finder_sql
      sql += sanitize_sql " and #{options[:conditions]}" if options[:conditions]
      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end
  #我的回复
  has_many :my_comments,:class_name=>"Comment" ,:dependent=>:destroy , :finder_sql => 'select *  from comments
 where user_id in (#{ids.join(\',\')})' do
    def find(*args)
      options = args.extract_options!
      sql = @finder_sql
      sql += sanitize_sql " and #{options[:conditions]}" if options[:conditions]
      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end
  
  has_many :reply_topics,:class_name=>"Topic",
    :finder_sql=>'
    selECT DISTINCT `topics`.*
    FROM `topics` INNER JOIN `comments` ON `topics`.id = `comments`.commentable_id AND `comments`.commentable_type = \'Topic\'
    WHERE `comments`.user_id in  (#{ids.join(\',\')}) order by topics.last_comment_datetime desc' do
    def find(*args)
      options = args.extract_options!
      sql = @finder_sql
      sql += sanitize_sql " and #{options[:conditions]}" if options[:conditions]
      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end
  
  #我发言的话题 包括 马甲创建的
  has_many :my_created_topics,:class_name=>"Topic" ,:dependent=>:destroy ,
    :finder_sql =>'select * from topics where author_id in  (#{ids.join(\',\')}) order by topics.created_at desc ' do
    def find(*args)
      options = args.extract_options!
      sql = @finder_sql
      sql += sanitize_sql " and  #{options[:conditions]}" if options[:conditions]
      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
    
    def all(*args)
      options = args.extract_options!
      sql = @finder_sql
      sql += sanitize_sql " and  #{options[:conditions]}" if options[:conditions]
      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end

  #参与小组的话题
  has_many :my_follow_group_topics ,:class_name=>"Topic",
    :finder_sql => 'select topics.* from topics INNER JOIN  members on topics.owner_id=members.group_id and topics.owner_type=\'Group\'
 where members.user_id in (#{ids.join(\',\')}) order by topics.last_comment_datetime desc' do
    def find(*args)
      options = args.extract_options!
      sql = @finder_sql
      sql += sanitize_sql " and #{options[:conditions]}" if options[:conditions]
      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end
  #关注公司的博客
  has_many :my_follow_company_news,:class_name=>"Piecenews",
    :finder_sql => 'select news.* from news INNER JOIN  attentions
      on attentions.target_id=news.company_id and attentions.target_type=\'Company\'
      where attentions.user_id = #{id} order by news.created_at desc' do
    def find(*args)
      options = args.extract_options!
      sql = @finder_sql
      sql += sanitize_sql " and #{options[:conditions]}" if options[:conditions]
      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end
  #用户拥有的别名
  has_many :aliases,
    :class_name => 'User',
    :foreign_key => 'parent_id',
    :dependent => :destroy
  
  #发布的招聘信息
  has_many :published_jobs,:class_name=>"Job",:foreign_key => "create_user_id"
  #发布的招聘信息 申请记录
  has_many :published_job_applicants,:through=>:published_jobs,:source=>:applicants,
    :conditions=>"is_deleted_by_published<>true",:order=>"is_read ,created_at desc"

  has_many :unread_published_job_applicants,:through=>:published_jobs,:source=>:applicants,
    :conditions=>"is_deleted_by_published<>true and not is_read"

  #工作申请记录
  has_many :job_applicants,:class_name=>'JobApplicant',:foreign_key=>'applicant_id',
    :conditions=>"is_deleted_by_applicant<>true"

  #申请过的工作
  has_many :applied_jobs,:through=>:job_applicants,:source=>'job'


  # 别名的父账号
  belongs_to :parent,
    :class_name => 'User',
    :foreign_key => 'parent_id'
  #当前简历信息
  has_one :current_resume,:class_name=>"Resume",:foreign_key=>"user_id",:conditions=>"is_current=#{true}",:dependent => :destroy
  has_one :icon,:class_name=>"UserIcon",:foreign_key=>"master_id",:dependent=>:destroy
  has_one :setting,:class_name=>"UserSetting",:foreign_key => "user_id",:dependent=>:destroy
  
  delegate :passes,:to=>:current_resume
  delegate :pass_companies,:to=>:current_resume
  delegate :current_passes,:to=>:current_resume
  delegate :current_companies,:to=>:current_resume

  #实际用户
  named_scope :real_users,:conditions=>["parent_id=0"]

  #最新加入
  named_scope :newly_order,:order=>"users.created_at desc"

  #回调函数
  def before_create
    if !parent
      self.aliases.build(:email=>"alias_email"+ self.email,
        :nick_name=>"马甲",:text_password=>self.text_password,
        :text_password_confirmation=>self.text_password_confirmation)
      self.resumes.build(:user_name=>self.nick_name,:is_current=>true)
      self.setting= UserSetting.new
      self.is_active = true
    end
  end

  #== 类方法开始
  
  #返回匿名用户
  def self.anonymity
    User.new()
  end
  #是否匿名用户
  def anonymity?
    new_record?
  end
  
  #END:加密密码
  #判断用户名、密码是否正确.两个参数，正确时第一个参数返回0,"成功"和用户对象，-1 “邮件不存在” -2 “密码错误”
  def  self.login(email,password)
    user = User.real_users.find_by_email(email)
    return (user ? (user.password==encrypted_password(password,user.salt) ? 0 :-2) :-1),user
  end
  #检查用户的授权 是否成功
  #  def  self.authenticate(user)
  #    "成功"
  #  end
  ####类方法结束

  #返回用户姓名
  def name
    anonymity? ? "匿名" : nick_name
  end
  #用户的状态 名称
  def state_string
    User::STATE_TYPES[state.to_sym || :working]
  end
  #用户的 所有关联账号的 id 数组 [1,2,……]
  def ids
    is_alias? ? [parent_id,id] : [id]+alias_ids
  end

  #已经评价的同事的id 数组
  def judged_yokemate_ids
    judged.empty? ? [-1] : judged.collect{ |obj| obj.user_id } 
  end

  #已经评价的公司的id 数组
  def judged_company_ids
    judged_companies.empty?  ? [-1] : judged_companies.collect{ |obj| obj.company_id }
  end
  #当前user 的所有账号 包括自己 数组
  def accounts
    [self]+aliases
  end

  def name_with_email
    if parent
      "'#{parent.name}' <#{parent.email}>"
    else
      "'#{name}' <#{email}>"
    end
  end
  
  #根据 id 获取当前 马甲账号 或 自己本身
  def get_account(id)
    aliases.find_by_id(id) ||  self
  end
  #是马甲账号吗
  def is_alias?
    parent_id!=0
  end
  #是否好友
  def is_friend?(user)
    friend_users.exists?(user)
  end
  #当前的短语
  def my_phrase
    my_languages.current_phrase ?  my_languages.current_phrase.content : ""
  end
  
  #图标 文件路径
  def icon_file_path(thumbnail=nil)
    if (thumbnail)
      icon ? (icon.public_filename(thumbnail)) : "default_user_thumb.png"
    else
      icon ? (icon.public_filename) : "default_user.png"
    end
  end
  #添加为好友
  def add_friend(user)
    friend_users << user unless is_friend?(user)
    my_follow_users << user unless  my_follow_users.exists?(user)
  end
  #解除好友
  def remove_friend(friend)
    friend_users.delete(friend) &&   my_follow_users.delete(friend)
  end
  
  #用户关注 某个对象 如 company 或 user
  def add_attention(target_object)
    targets << target_object
  end
  #解除关注
  def remove_attention(target_object)
    targets.delete(target_object)
  end
  #右上角 說點什麽 
  def say_something(phrase)
    if (phrase.to_s.blank? && self.my_languages.current_phrase)
      self.my_languages.current_phrase.cancel_current
    else
      if  self.my_phrase!=phrase
        self.my_languages << MyLanguage.new(:content=>phrase,:is_current=>true)
      end
    
    end
  end
  
  #用户 用过的标签
  def used_tags(judge_object=nil)
    self.user_taggings.find(:all,:select=>"tags.*",:joins=>"join tags on taggings.tag_id=tags.id",
      :conditions=>judge_object ? {:taggable_id=>judge_object.id,
        :taggable_type=>judge_object.class.to_s} : "")
  end
 
  #平均 评价的评分
  def avg_judge_value(judge_name=nil)
    fv = self.passes.sum("judges_count")
    if (fv)>0
      if judge_name
        (self.passes.sum(judge_name) / fv).to_f.round(1)
      else
        (self.passes.sum("eq_value+creditability_value+ability_value" ).to_i / fv / 3 ).to_f.round(1)
      end
    else
      0.0
    end
  end
  

  def text_password=(value)
    @text_password=value
    create_new_salt
    self.password = User.encrypted_password(value,salt)
  end

  #仅仅在创建新对象的时候，才返回密码明文，其他返回空 ？有点问题
  def text_password
    @text_password
  end

  #获取用户 对 某个对象 做的标签的文本
  def used_tags_text(taggable_object)
    return  if  !taggable_object.taggable?
    taggble_list = self.used_tags(taggable_object)
    #获取 当前评价
    !taggble_list.empty?  ? taggble_list.collect.map { |item| item.name }.join(Tag::DELIMITER) : []
  end
  
  #对某个可以做 做标签 的对象做标签 如公司
  def tag_something(taggable_object,tags=[])
    return  if  !taggable_object.taggable?  || taggable_object.tag_list == tags
    list = tag_cast_to_string(tags)
 
    current = []
    tagging_list = user_taggings.find(:all,:conditions=>{:taggable_id=>taggable_object.id,
        :taggable_type=>taggable_object.class.to_s.camelize})
    #获取 当前的标签
    current = tagging_list.collect.map { |item| item.tag.name } if tagging_list
    #需要新添加的标签
    add_list = list-current
   
    destroy_list = current - list
    add_list.each do |tag_name|
      temp_tag = Tag.find_or_create_by_name(tag_name)
      temp_tagging = taggable_object.taggings.find_by_tag_id(temp_tag)
      #是否有同样的标签
      if !temp_tagging
        taggable_object.tags << temp_tag
        temp_tagging = taggable_object.taggings.find_by_tag_id(temp_tag)
      end
      user_tags << UserTag.new(:tagging=>temp_tagging)
    end
    #    user_tags.find(:all,:conditions=>
    #        ["tags.name in (?)",destroy_list],
    #      :joins=>"join tags  join taggings on tags.id=taggings.tag_id and taggings.id=user_tags.tagging_id").each do |tag_name|
    #      tag_name.destroy
    #需要删除的标签
    destroy_list.each do |tag_name|
      temp_tag = Tag.find_or_create_by_name(tag_name)
      temp_tagging = taggable_object.taggings.find_by_tag_id(temp_tag) if temp_tag
      user_tags.find_by_tagging_id(temp_tagging).destroy if temp_tagging
    end
  end
  #删除 对某个对象做的 标签
  def remove_something_tag(taggable_object)
    tag_something(taggable_object)
  end
  #START:create_new_salt
  def create_new_salt
    self.salt = self.object_id.to_s + rand.to_s
  end
  #END:create_new_salt
  #未评价的同事
  def unjudge_yokemates(pass=nil)
    if pass
      pass.yokemates.find(:all,:conditions=>["a.user_id not in (?)",judged_yokemate_ids ])
    else
      current_resume.yokemates.all(:conditions=>["b.user_id not in (?)",judged_yokemate_ids ])
    end
  end
  #未评价的公司
  def unjudge_companies
    current_resume.pass_companies.all(:conditions=>["company_id not in (?)",judged_company_ids ])
  end

  private
  #  #START:encrypted_password
  def self.encrypted_password(password, salt)
    string_to_hash = password + "salt" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  #  #END:encrypted_password
end
