# == Schema Information
#
# Table name: comments
#
#  id               :integer       not null, primary key
#  commentable_id   :integer       not null
#  up               :integer       default(0)
#  down             :integer       default(0)
#  content          :string(255)   not null
#  user_id          :integer       not null
#  created_at       :datetime      
#  updated_at       :datetime      
#  commentable_type :string(255)   
#

class Comment < ActiveRecord::Base
 
  
  belongs_to :commentable ,:polymorphic => true,:counter_cache=>true # , :touch => true 2.3.4使用的 添加删除 comments的时候 更新 topic的 updated_at
  belongs_to :user ,:class_name=>"User",:foreign_key=>"user_id"

  has_many :votes,:as=>:owner
    
  named_scope :higher_scope,:conditions=>["comments.up-comments.down>10"],:order=>"comments.up-comments.down desc"
  named_scope :news_comments,:conditions=>["commentable_type=?",Piecenews.class.to_s]

  #添加投票
  def add_vote(vote)
    if vote.value>0
      self.up +=1
    else
      self.down += 1
    end
    self.votes << vote
    self.save!
  end

    #是否作者
  def is_author?(user_m)
    user_m && user_m.accounts.index(self.user)
  end
end
