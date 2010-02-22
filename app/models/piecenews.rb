# == Schema Information
#
# Table name: news
#
#  id                :integer       not null, primary key
#  company_id        :integer       
#  title             :string(255)   
#  content           :text          
#  create_user_id    :integer       
#  last_edit_user_id :integer       
#  created_at        :datetime      
#  updated_at        :datetime      
#  up                :integer       default(0)
#  down              :integer       default(0)
#  comments_count    :integer       
#

class Piecenews < ActiveRecord::Base
  #记录公司 加入人
  #  acts_as_logger :log_action=>["create"],:owner_attribute=>"company",:log_type=>"join_company",:logable=>"create_user"
  acts_as_logger :log_action=>["create"],:owner_attribute=>"owner",:log_type=>"company_news"

  belongs_to :owner,:class_name=>"Company",:foreign_key=>"company_id"
  belongs_to :create_user ,:class_name=>"User",:foreign_key=>"create_user_id"
  belongs_to :last_edit_user ,:class_name=>"User",:foreign_key=>"last_edit_user_id"
  named_scope :populars,:conditions=>["(up-down)>10"],:order=>"up-down desc"
  named_scope :most_recommand,:order=>"recommends_count desc"
  has_many :comments ,:as=>:commentable,:dependent=>:destroy

  has_many :recommends,:as=>:recommendable,:dependent=>:destroy
  #动态信息
  has_many :log_items,:as=>:owner,:dependent => :destroy
  has_many :votes,:as=>:owner

end
