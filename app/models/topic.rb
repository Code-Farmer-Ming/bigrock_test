# == Schema Information
#
# Table name: topics
#
#  id                    :integer       not null, primary key
#  owner_id              :integer       not null
#  owner_type            :string(255)   not null
#  author_id             :integer       not null
#  title                 :string(128)   not null
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
  validates_length_of :title, :within => 3..128
  validates_length_of :content, :minimum => 4
  
  belongs_to :owner,:polymorphic => true,:counter_cache => true
  belongs_to :author,:class_name=>"User",:foreign_key=>"author_id"
  #  belongs_to :last_comment_user ,:class_name=>"User",:foreign_key=>"last_comment_user_id"
  belongs_to :group_type 
  
  has_many :recommends,:as=>:recommendable,:dependent=>:destroy
  has_many :comments,:as=>:commentable,:dependent=>:destroy
  has_many :votes,:as=>:owner


  #热门话题
  #TODO 加上 日期限制 近期最热门的话题
  named_scope :hot,:conditions=>["view_count>10"],:order=>"view_count desc"
  #评分最高的话题
  named_scope :highter_scope,:conditions=>["(up-down)>10"],:order=>"up-down desc"

  named_scope :new_topics,:order=>"topics.created_at desc"
  named_scope :group_topics,:conditions=>["owner_type='Group'"]
 
  #相关的话题
  def related_topics(limit=10)
    owner.topics.new_topics(:conditions=>["id<>?",self], :limit=>limit)
  end
  
  def last_comment
    comments.last
  end

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

end
