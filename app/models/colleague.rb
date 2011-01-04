# == Schema Information
#
# Table name: colleagues
#
#  id           :integer       not null, primary key
#  user_id      :integer       
#  colleague_id :integer       
#  created_at   :datetime      
#  updated_at   :datetime      
#  company_id   :integer       
#  pass_id      :integer       
#  state        :string(255)   default("未定")
#  is_judge     :boolean       
#

#同事
class Colleague < ActiveRecord::Base
  STATES = ["未定","同事", "不是同事"]
  
  #  validates_uniqueness_of :user_id, :scope =>:colleague_id,:message =>"已经是同事啦"
  belongs_to :user,:class_name=>"User",:foreign_key=>"user_id"
  belongs_to :colleague_user,:class_name=>"User",:foreign_key=>"colleague_id"
  belongs_to :company ,:class_name=>"Company",:foreign_key=>"company_id"

  belongs_to :my_pass,:class_name=>"Pass",:foreign_key=>"my_pass_id"
  belongs_to :colleague_pass,:class_name=>"Pass",:foreign_key=>"colleague_pass_id"
  
  #互为同事
#  belongs_to :sideA,:class_name=>"Colleague",:foreign_key=>"colleague_pass_id"
#  has_one :sideB,:class_name=>"Colleague",:primary_key=>"colleague_pass_id",:dependent=>:destroy,:foreign_key=>"my_pass_id"

  has_one :judge,:dependent=>:destroy
  
#  has_one :colleague_user ,:class_name=>"User",:through=>:colleague_pass,:source => :user
#  has_one :my ,:class_name=>"User",:through=>:my_pass,:source => :user

  acts_as_logger :log_action=>["create","destroy"],:owner_attribute=>"user",:logable=>"colleague_user"
  
  def add_judge(judge)
    self.judge = judge
  end
end
