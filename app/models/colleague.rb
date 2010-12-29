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
  belongs_to :colleague,:class_name=>"User",:foreign_key=>"colleague_id"
  belongs_to :company ,:class_name=>"Company",:foreign_key=>"company_id"

  belongs_to :my_pass,:class_name=>"Pass",:foreign_key=>"my_pass_id"
  belongs_to :colleague_pass,:class_name=>"Pass",:foreign_key=>"colleague_pass_id"
  
  #互为同事
  belongs_to :sideA,:class_name=>"Colleague",:foreign_key=>"colleague_pass_id"
  has_one :sideB,:class_name=>"Colleague",:primary_key=>"my_pass_id",:dependent=>:destroy,:foreign_key=>"colleague_pass_id"

  has_one :judge,:dependent=>:destroy
  acts_as_logger :log_action=>["create","destroy"],:owner_attribute=>"user",:logable=>"colleague"
  
  def add_judge(judge)
    self.judge = judge
  end
  #  def after_create
  #    msg =  Msg.new_system_msg(:title=>"有同事新加入了",:content=>"<a href='/users/#{user.id}'>#{user.name}</a>新加入了<a href='/companies/#{company.id}'>#{company.name}</a>快去看看吧。")
  #    #    msg= Msg.new_system_msg(:title=>"系统提示：#{user.name}已经把你当做同事",:content=>"#{user.name}已经加你为好友,去看看吧。")
  #    msg.send_to(colleague)
  #  end
end
