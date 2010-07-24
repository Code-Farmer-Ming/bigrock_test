# == Schema Information
#
# Table name: groups
#
#  id               :integer       not null, primary key
#  name             :string(255)   not null
#  description      :text          default(""), not null
#  group_type_id    :integer       not null
#  join_type        :string(255)   not null
#  create_user_id   :integer       not null
#  members_count    :integer       default(0)
#  topics_count     :integer       default(0)
#  created_at       :datetime      
#  updated_at       :datetime      
#  recommends_count :integer       default(0)
#

class Group < ActiveRecord::Base
  validates_uniqueness_of :name
  validates_length_of :name, :within => 3..35
  #加入小组的类型 开放型 申请型 保密型
  JOIN_TYPES=[["开放式小组","open"],["需申请小组","application"]]
  
  belongs_to :create_user,:class_name=>"User",:foreign_key=>"create_user_id"
  #图标
  has_one :icon,:class_name=>"GroupIcon",:foreign_key=>"master_id",:dependent=>:destroy

  has_many :topics,:as=>:owner,:dependent=>:destroy 
  
  has_many :comments ,:through => :topics
  #所有成员
  has_many :members,:dependent=>:destroy
  #root 组长
  has_many :roots ,:dependent=>:destroy
  #manager 管理员
  has_many :managers ,:dependent=>:destroy
  #normal 普通组员
  has_many :normals ,:dependent=>:destroy
  has_many :all_members,:through => :members,:source=>:user,:order=>"members.created_at desc"
  #该小组成员同时喜欢去的小组
  has_many :related_popular_groups,:class_name=>"Group",
    :finder_sql=>'select v.* from (select x.id,count(*) from (select a.* ,b.user_id from groups a
              join members b on a.id=b.group_id ) z
              join (select c.* ,d.user_id from groups c
              join members d on c.id=d.group_id) x  on z.user_id=x.user_id and z.id<>x.id and z.id=#{id}
              group by x.id order by  count(*) desc ) u join groups v on u.id=v.id ',
    :counter_sql=>'select count(*) from (select x.id,count(*) from (select a.* ,b.user_id from groups a
              join members b on a.id=b.group_id ) z
              join (select c.* ,d.user_id from groups c
              join members d on c.id=d.group_id) x  on z.user_id=x.user_id and z.id<>x.id and z.id=#{id}
              group by x.id order by  count(*) desc ) u'  do
    def all(*args)
      options = args.extract_options!
      sql = @finder_sql

      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end
  #相同标签的小组
  has_many :similar_tag_groups,:class_name=>"Group",
    :finder_sql=>'select * from (select id ,sum(tags) tag_count,count(1) same_tags
                                from (select e.taggable_id id ,e.user_tags_count tags from
                                      (select * from  taggings d where #{id}<>d.taggable_id and d.taggable_type=\'Group\' ) e
                                      join
                                      (select * from   taggings b where #{id}=b.taggable_id and b.taggable_type=\'Group\' ) f
                                     on e.tag_id=f.tag_id ) g
                                    group by id
                                    order by same_tags desc,tag_count desc) y join groups z on y.id=z.id ' do
    def all(*args)
      options = args.extract_options!
      sql = @finder_sql

      sql += sanitize_sql [" order by %s", options[:order]] if options[:order]
      sql += sanitize_sql [" LIMIT ?", options[:limit]] if options[:limit]
      sql += sanitize_sql [" OFFSET ?", options[:offset]] if options[:offset]
      find_by_sql(sql)
    end
  end

  #普通成员
  has_many :normal_members ,:through => :normals ,:source=>:user
  #所有管理員 (包括 组长)
  has_many :all_manager_members ,:through => :members,:source=>:user,
    :conditions=>["members.type=? or members.type=?",Member::MEMBER_TYPES[1],Member::MEMBER_TYPES[0]]
 
  #一般管理员
  has_many :manager_members,:through => :managers,:source=>:user
  #小组组长
  has_many :root_members ,:through => :roots,:source=>:user

  #加入小组  申请
  has_many :add_applications ,:foreign_key=>"respondent_id",
    :dependent=>:destroy,:class_name=>"AddGroupApplication",:source=>:applicant
  #推荐
  has_many :recommends,:as=>:recommendable,:dependent=>:destroy,:order=>"created_at desc"

  #被动 作为 消息记录的内容
  has_many :logable_log_items,:class_name=>"LogItem",:as=>:logable,:dependent => :destroy,:order=>"created_at desc"
  
  #新创建的 小组
  named_scope :new_groups,:order=>"created_at desc"
  #帖子最多的小组
  named_scope :most_topics_groups,:order=>"topics_count desc"
  named_scope :most_activity,:order=>"updated_at desc"
  #推荐最多的小组
  named_scope :most_recommend_groups,:order=>"recommends_count desc"
  validates_uniqueness_of  :name

  def before_create
    self.group_type_id = 0
    self.root_members << create_user
  end
  #是否小组的成员
  def is_member?(user)
    user && all_members.first(:conditions=>["users.id in (?)",user.ids])
  end
  #加入为成员（普通成员）
  def add_to_member(user)
    all_members << user unless is_member?(user)
  end
  #移除成员
  def remove_member(user)
    if  can_operation_root?(user)
      return all_members.delete(user)
    end
  end
  #是否小组的管理人员 （包括组长）
  def is_manager_member?(user)
    if  !(user && all_manager_members.exists?(["users.id in (?)",user.ids]))
      return  !errors.add("权限","不是管理员的权限。")
    else
      true
    end

  end
  #是否管理员(不包括 组长 root)
  def is_manager?(user)
    return !errors.add("权限","不是管理员的权限。") unless manager_members.exists?(["users.id in (?)",user.ids])
    
 
  end
  #是否小组的组长
  def is_root?(user)
    user && root_members.exists?(["users.id in (?)",user.ids])
  end
  #是否 开放式加入
  def is_open_join?
    join_type==Group::JOIN_TYPES[0][1]
  end
  #把一个成员提升为组长
  def to_root(user)
    if (self.roots.size<2)
      member = self.members.find_by_user_id(user.to_param)
      member.update_attribute("type",Member::MEMBER_TYPES[0] ) if member
      return true
    else
      !errors.add("限制","小组最多只能有2个组长。")
    end
  end
  #把一个成员 变为 管理员
  def to_manager(user)
    if can_operation_root?(user)
      if  self.managers.size<10
        member = self.members.find_by_user_id(user.to_param)
        member.update_attribute("type",Member::MEMBER_TYPES[1] ) if member
        return true
      else
        !errors.add("限制","小组最多只能有10个管理员。")
      end
    end
  end

  def to_normal(user)
    if can_operation_root?(user)
      member = self.members.find_by_user_id(user.to_param)
      member.update_attribute("type",Member::MEMBER_TYPES[2] ) if member
    end
  end
  #是否 还可以创建小组，现在管理小组的数量不能多于4个
  def self.can_create?(user)
       user.manage_groups.size<=4
  end
  
  #图标 文件路径
  def icon_file_path(thumbnail=nil)
    if (thumbnail.nil?)
      icon ? (icon.public_filename) : "default_group.png"
    else
      icon ? (icon.public_filename(thumbnail)) : "default_group_thumb.png"
    end
  end


  private
  
  def can_operation_root?(user)
    return true  unless is_root?(user) && roots.size==1
    !errors.add("限制","小组必须有一个组长，在指定其他人为组长后才能退出。")
  end
end
