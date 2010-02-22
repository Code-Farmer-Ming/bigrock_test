# == Schema Information
#
# Table name: topics
#
#  id                    :integer       not null, primary key
#  owner_id              :integer       not null
#  owner_type            :string(255)   default(""), not null
#  author_id             :integer       not null
#  title                 :string(128)   default(""), not null
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
#

class Topic < ActiveRecord::Base
  belongs_to :owner,:polymorphic => true,:counter_cache => true
  belongs_to :author,:class_name=>"User",:foreign_key=>"author_id"
  #  belongs_to :last_comment_user ,:class_name=>"User",:foreign_key=>"last_comment_user_id"
  belongs_to :group_type 
  
  has_many :recommends,:as=>:recommendable,:dependent=>:destroy
  has_many :comments,:as=>:commentable,:dependent=>:destroy
  has_many :votes,:as=>:owner


  #热门话题
  named_scope :hot_topic,:conditions=>["up>10"],:order=>"up desc"
  named_scope :new_topics,:order=>"topics.created_at desc"
  named_scope :group_topics,:conditions=>["owner_type='Group'"]
 
  #相关的话题
  def related_topics(limit=10)
    owner.topics.all(:conditions=>["id<>?",self], :order=>"up-down desc" ,:limit=>limit)
  end
  
  def last_comment
    comments.last
  end

end
