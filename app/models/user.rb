# == Schema Information
#
# Table name: users
#
#  id         :integer       not null, primary key
#  email      :string(255)   default(""), not null
#  password   :string(255)   default(""), not null
#  is_active  :boolean       
#  created_at :datetime      
#  updated_at :datetime      
#  nick_name  :string(128)   
#  parent_id  :integer       default(0), not null
#  state      :string(12)    default("working")
#


class User< ActiveRecord::Base
  #状态
  STATE_TYPES= {:working=>"我工作很好",:freedom=>"我需要工作",:student=>"我还在学校"}

  
  #我的简历
  has_many :resumes,:foreign_key=>"user_id",:dependent=>:destroy
  #经历
  has_many :passes,:foreign_key=>"user_id" ,:order=>"begin_date desc,is_current desc"
  #当前所在的公司 可能当前就职于多家公司 不考虑多个简历的问题
  has_many :current_companies ,:through=>:passes,:source=>:company
  #别人对自己的评价
  has_many :judges,:foreign_key=>"user_id",:dependent=>:destroy
  #自己对别人的评价
  has_many :judged,:class_name=>"Judge",:foreign_key=>"judger_id",:dependent=>:destroy
  #对所在公司的评价
  has_many :judged_companies,:class_name=>"CompanyJudge",:foreign_key=>"user_id",:dependent=>:destroy

  #好友
  has_many :friends,:foreign_key=>"user_id",:dependent=>:destroy
  has_many :friends_user,:through=>:friends,:source=>:friend
  has_many :created_news,:class_name=>"Piecenews",:foreign_key=>"create_user_id",:dependent=>:destroy
  
  #  #添加好友 申请
  has_many :add_friend_applications ,:foreign_key=>"respondent_id",
    :dependent=>:destroy,:class_name=>"AddFriendApplication",:source=>:applicant
  # 小组邀请
  has_many :join_group_invites ,:foreign_key=>"respondent_id",
    :dependent=>:destroy,:class_name=>"JoinGroupInvite",:source=>:applicant
  #发起的消息
  has_many :send_msgs,:class_name=>"Msg",
    :finder_sql=>'SELECT * FROM `msgs` WHERE sender_stop=#{false} and sender_id in (#{ids.join(\',\')})' do
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
    :finder_sql=>'SELECT * FROM `msgs` WHERE sendee_stop=#{false} and sendee_id in (#{ids.join(\',\')})' do
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
  has_many  :new_msgs,:class_name=>"Msg",:finder_sql =>
    'SELECT DISTINCT a.* ' +
    'FROM msgs a left join msg_responses b on a.id=b.msg_id ' +
    'WHERE (a.sender_id in (#{ids.join(\',\')}) and a.sender_stop=false and ( (b.sender_id not in (#{ids.join(\',\')}) and b.is_check=#{false}))  ) '+
    'or (a.sendee_id in (#{ids.join(\',\')}) and a.sendee_stop=false and (a.is_check=#{false} or (b.sender_id not in (#{ids.join(\',\')}) and b.is_check=#{false}) )) '+
    "  order by a.created_at",
    :counter_sql=> 'select count(*) from (SELECT DISTINCT a.* ' +
    'FROM msgs a left join msg_responses b on a.id=b.msg_id ' +
    'WHERE (a.sender_id = #{id} and a.sender_stop=false and ((b.sender_id<>#{id} and b.is_check=#{false}))  ) '+
    'or (a.sendee_id = #{id} and a.sendee_stop=false and (a.is_check=#{false} or (b.sender_id<>#{id} and b.is_check=#{false}) )) ) new_msgs' do
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
  has_many :taggings,:through => :user_tags

  #动态信息
  has_many :log_items,:as=>:owner,:dependent => :destroy,:order=>"created_at desc"

  #  has_many :my_follow_collection,:class_name=>"Attention",:as=>:target
  #跟随我的用户
  has_many :follow_me_collection ,:class_name=>"Attention",:as=>:target,:dependent => :destroy
  has_many :follow_me_users,:through=>:follow_me_collection,:source=>:user 
  #  has_many :my_follow,:through=>:my_follow_collection,:source=>:target
  #我跟随的用户或公司或其他
  has_many :my_follow_collection,:class_name=>"Attention",:foreign_key=>"user_id",:dependent => :destroy
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
  has_many :recommends,:foreign_key=>"user_id";

  has_many :members ,:foreign_key=>"user_id"
  #参加的小组
  has_many :groups,:through => :members,:source=>:group,:order=>"members.created_at desc"
  #管理的小组
  has_many :manage_groups,:class_name=>"Group",
    :finder_sql => 'select groups.* from groups INNER JOIN  members on groups.id=members.group_id 
                  where user_id in (#{ids.join(\',\')})'+
    " and (members.member_type='#{Member::MEMBER_TYPES[0]}' or members.member_type='#{Member::MEMBER_TYPES[1]}')",
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
  #
  has_many :my_comments,:class_name=>"Comment",:foreign_key=>"user_id"
  has_many :join_topics,:through=>:my_comments,:source=>:commentable,:source_type=>"Topic",:uniq => :true,:order=>"topics.created_at desc"
  #我发言的话题  
  has_many :my_topics,:class_name=>"Topic" ,:foreign_key=>"author_id",:dependent => :destroy
  #我发言的话题 包括 马甲创建的
  has_many :my_created_topics,:class_name=>"Topic" ,
    :finder_sql =>'select * from topics where author_id=#{id} or author_id= #{aliases.first.id}' do
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
  #关注公司的新闻
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
  
  # 别名的父账号
  belongs_to :parent,
    :class_name => 'User',
    :foreign_key => 'parent_id'
  
  has_one:current_resume,:class_name=>"Resume",:foreign_key=>"user_id",:conditions=>"is_current=#{true}"
  has_one :icon,:class_name=>"UserIcon",:foreign_key=>"master_id",:dependent=>:destroy
  has_one :setting,:class_name=>"UserSetting",:foreign_key => "user_id",:dependent=>:destroy
  #字段验证
  validates_presence_of       :email,:password
  validates_uniqueness_of     :email, :message=>"邮件地址不能重复"
  attr_accessor                 :text_password
  validates_confirmation_of   :text_password,  :message=>"两次密码不同"
  attr_accessor                 :text_password_confirmation

  #实际用户
  named_scope :real_users,:conditions=>["parent_id=0"]

  #== 类方法开始
  
  #返回匿名用户
  def self.anonymity
    User.new()
  end
  #是否匿名函数
  def anonymity?
    new_record?
  end

  
  #END:加密密码
  #判断用户名、密码是否正确.返回一个数组，正确时第一个元素返回值"成功"和用户对象，否则 “邮件不存在” “密码错误”和空
  def  self.login(email,password)
    user= User.real_users.find_by_email(email)
    if user==nil
      ["#{email}用户不存在" ,user=nil]
    else if (user.password!=encrypted_password(password,user.salt))
        ["密码错误" ,user=nil]
      else
        [authenticate(user) ,user]
      end
    end
  end
  #检查用户的授权 是否成功
  def  self.authenticate(user)
    "成功"
  end
  ####类方法结束

  #返回用户姓名
  def name
    parent ? nick_name  : (current_resume ? current_resume.user_name : "" )
    #    current_user?(self) ? "我" : current_resume.user_name
  end
  #用户的 所有关联账号的 id 数组 [1,2,……]
  def ids
    [id]+alias_ids
  end
  #当前user 的所有账号 包括自己 数组
  def accounts
    [self]+aliases
  end
  
  #根据 id 获取当前 马甲账号 或 自己本身
  def get_account(id)
    aliases.find_by_id(id) ||  self
  end
  #是马甲账号吗
  def is_alias?
    parent_id!=0
  end
  
  def my_language
    top_language = my_languages.current_language
    top_language ? top_language.content : ""
  end
  #图标 文件路径
  def icon_file_path(thumbnail=nil)
    if (thumbnail)
      icon ? (icon.public_filename(thumbnail)) : "default_user_thumb.png"
    else
      icon ? (icon.public_filename) : "default_user.png"
    end
  end
  #评价平均评价值
  def avg_judge_value
    value = judges.all(:select=>["avg(eq_value+creditability_value+ability_value)/3  avg_judge_value"])[0].avg_judge_value
    ((value && (value.is_a?(Fixnum) ? value.to_f : value)) || 0).to_f.round(1)
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

  #获取用户的做的标签
  def get_tags(taggable_object)
    return  if  !taggable_object.taggable?
    taggble_list = self.taggings.find(:all,:conditions=>{:taggable_id=>taggable_object.id,
        :taggable_type=>taggable_object.class.to_s.camelize})
    #获取 当前评价
    taggble_list ? taggble_list.collect.map { |item| item.tag.name }.join(Tag::DELIMITER) : []
  end
  
  #对某个可以做 做标签 的对象做标签 如公司
  def tag_something(taggable_object,tags=[])
    return  if  !taggable_object.taggable?  || taggable_object.tag_list == tags
    list = tag_cast_to_string(tags)
 
    current = []
    tagging_list = taggings.find(:all,:conditions=>{:taggable_id=>taggable_object.id,
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
  private
  #  #START:encrypted_password
  def self.encrypted_password(password, salt)
    string_to_hash = password + "salt" + salt
    Digest::SHA1.hexdigest(string_to_hash)
  end
  #  #END:encrypted_password
end
