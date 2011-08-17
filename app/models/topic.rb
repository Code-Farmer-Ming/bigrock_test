# == Schema Information
#
# Table name: topics
#
#  id                    :integer       not null, primary key
#  owner_id              :integer       not null
#  owner_type            :string(255)   default(""), not null
#  author_id             :integer       not null
#  title                 :string(128)   
#  content               :text          default(""), not null
#  up                    :integer       default(0)
#  down                  :integer       default(0)
#  comments_count        :integer       default(0)
#  view_count            :integer       default(0)
#  created_at            :datetime      
#  updated_at            :datetime      
#  top_level             :boolean       
#  can_comment           :boolean       default(TRUE)
#  last_comment_user_id  :integer       
#  last_comment_datetime :datetime      
#  recommends_count      :integer       default(0)
#

class Topic < ActiveRecord::Base
  validates_length_of :title, :maximum => 64
  validates_length_of :content, :minimum => 2
  
  belongs_to :owner,:polymorphic => true,:counter_cache => true
  belongs_to :author,:class_name=>"User",:foreign_key=>"author_id"
  belongs_to :last_comment_user ,:class_name=>"User",:foreign_key=>"last_comment_user_id"
  belongs_to :group_type 
  
  has_many :recommends,:as=>:recommendable,:dependent=>:destroy
  has_many :comments,:as=>:commentable,:dependent=>:destroy
  has_many :votes,:as=>:owner


  #热门话题
  named_scope :hot,:order=>"view_count desc"
  #评分最高的话题
  named_scope :highter_scope,:order=>"up-down desc"
  named_scope :limit,lambda { |size| { :limit => size } }
  named_scope :newly,:order=>"topics.created_at desc"
 
  named_scope :order_by_last_comment,:order=>"last_comment_datetime desc"
  named_scope :since,lambda { |since| { :conditions =>["created_at>?",since] } }

  named_scope :group_topics,:conditions=>["owner_type='Group'"]

  #置顶的并 最近回复排序
   named_scope :top_level_and_last_comment,:order=>"top_level desc,last_comment_datetime desc"


  def before_create
    self.last_comment_datetime = Time.now
  end
  #相关的话题
  def related_topics(limit=10)
    owner.topics.newly.all(:conditions=>["id<>?",self.id], :limit=>limit)
  end

  def add_comment(comment)
    comments << comment
    self.last_comment_user = comment.user
    self.last_comment_datetime = Time.now
    save
  end
  
  #  def last_comment
  #    last_comment_user.last
  #  end

  #浏览次数增加
  def increase_view_count
    update_attribute(:view_count, view_count+1)
  end

  def add_vote(vote)
    if vote.value>0
      self.up +=1
    else
      self.down += 1
    end
    self.votes << vote
    self.save!
  end
  #设置置顶
  def set_top
    update_attribute("top_level", true) unless top_level
  end
  #取消置顶
  def cancel_top
    update_attribute("top_level", false) unless !top_level
  end

  #检查当前用户的权限
  def is_manager?(user)
    if owner_type=="Group"#group topics
      owner.is_manager_member?(user)
    else #company topics
      owner.current_employee?(user)  #TODO:current_employee 需要做信用检查
      #       topic.owner.higher_creditability_employees.exists?(current_user)
    end
  end
  #是否作者
  def is_author?(user)
    user && user.accounts.index(author)
  end

end
