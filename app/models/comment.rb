# == Schema Information
#
# Table name: comments
#
#  id               :integer       not null, primary key
#  commentable_id   :integer       
#  up               :integer       default(0)
#  down             :integer       default(0)
#  content          :string(255)   
#  user_id          :integer       
#  created_at       :datetime      
#  updated_at       :datetime      
#  commentable_type :string(255)   
#

class Comment < ActiveRecord::Base
  belongs_to :commentable ,:polymorphic => true,:counter_cache=>true , :touch => true # 2.3.4使用的 添加删除 comments的时候 更新 topic的 updated_at
  belongs_to :user ,:class_name=>"User",:foreign_key=>"user_id"
  named_scope :hot_comments,:conditions=>["comments.up-comments.down>10"],:order=>"comments.up-comments.down desc"
  named_scope :news_comments,:conditions=>["commentable_type=?",Piecenews.class.to_s]
end
