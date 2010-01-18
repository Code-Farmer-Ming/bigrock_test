# == Schema Information
#
# Table name: groups
#
#  id             :integer       not null, primary key
#  name           :string(255)   default(""), not null
#  description    :text          default(""), not null
#  group_type_id  :integer       not null
#  join_type      :string(255)   default(""), not null
#  create_user_id :integer       not null
#  members_count  :integer       default(0)
#  topics_count   :integer       default(0)
#  created_at     :datetime      
#  updated_at     :datetime      
#

class Group < ActiveRecord::Base
  #加入小组的类型 开放型 申请型 保密型
  JOIN_TYPES=[["开放式小组","open"],["需申请小组","application"],["秘密小组","secrecy"]]
  belongs_to :create_user,:class_name=>"User",:foreign_key=>"create_user_id"
  #图标
  has_one :icon,:class_name=>"GroupIcon",:foreign_key=>"master_id",:dependent=>:destroy


  has_many :topics,:as=>:owner,:dependent=>:destroy,:order => 'top_level desc ,last_comment_datetime DESC'
  has_many :comments ,:through => :topics
  #所有成员
  has_many :members,:dependent=>:destroy
  has_many :all_members,:through => :members,:source=>:user,:order=>"members.created_at desc"
  #该小组成员同时喜欢去的小组
  has_many :related_popular_groups,:class_name=>"Group",
    :finder_sql=>'select v.* from (select x.id,count(*) from (select a.* ,b.user_id from groups a
              join members b on a.id=b.group_id ) z
              join (select c.* ,d.user_id from groups c
              join members d on c.id=d.group_id) x  on z.user_id=x.user_id and z.id<>x.id and z.id=#{id}
              group by x.id having  count(*)>5 order by  count(*) desc ) u join groups v on u.id=v.id ' do
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
  has_many :normal_members ,:through => :members,:source=>:user,:conditions=>["members.member_type=?",Member::MEMBER_TYPES[2]] do
    def <<(user)
      Member.send(:with_scope,:create => {:member_type =>Member::MEMBER_TYPES[0]}) { self.concat user }
    end
  end
  #所有管理員 (包括 组长)
  has_many :manager_members ,:through => :members,:source=>:user,
    :conditions=>["members.member_type=? or members.member_type=?",Member::MEMBER_TYPES[1],Member::MEMBER_TYPES[0]]
 
  #一般管理员
  has_many :managers,:through => :members,:source=>:user,:conditions=>["members.member_type=?",Member::MEMBER_TYPES[1]] do
    def <<(user)
      Member.send(:with_scope,:create => {:member_type =>Member::MEMBER_TYPES[1]}) { self.concat user }
    end
  end
  #小组组长
  has_many :roots ,:through => :members,:source=>:user,:conditions=>["members.member_type=?",Member::MEMBER_TYPES[0]] do
    def <<(user)
      Member.send(:with_scope,:create => {:member_type =>Member::MEMBER_TYPES[0]}) { self.concat user }
    end
  end

  #加入小组  申请
  has_many :add_applications ,:foreign_key=>"respondent_id",
    :dependent=>:destroy,:class_name=>"AddGroupApplication",:source=>:applicant
  #推荐
  has_many :recommends,:as=>:recommendable,:dependent=>:destroy

  #新创建的 小组
  named_scope :new_groups,:order=>"created_at desc"
  #帖子最多的小组
  named_scope :most_topics_groups,:order=>"topics_count desc"
  #推荐最多的小组
  named_scope :most_recommend_groups,:order=>"recommends_count desc"
  validates_uniqueness_of  :name
  #是否小组的成员
  def is_member?(user)
    user && all_members.exists?(["users.id in (?)",user.ids])
  end
  #是否小组的管理人员 （包括组长）
  def is_manager_member?(user)
    user && manager_members.exists?(["users.id in (?)",user.ids])
  end
  #是否管理员
  def is_manager?(user)
   user &&  managers.exists?(["users.id in (?)",user.ids])
  end
  #是否小组的组长
  def is_root?(user)
    user && roots.exists?(["users.id in (?)",user.ids])
  end
  #图标 文件路径
  def icon_file_path(thumbnail=nil)
    if (thumbnail.nil?)
      icon ? (icon.public_filename) : "default_group.png"
    else
      icon ? (icon.public_filename(thumbnail)) : "default_group_thumb.png"
    end
  end
end
