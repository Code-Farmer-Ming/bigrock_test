# == Schema Information
#
# Table name: attentions
#
#  id          :integer       not null, primary key
#  user_id     :integer       
#  target_id   :integer       
#  target_type :string(255)   
#  created_at  :datetime      
#  updated_at  :datetime      
#

class Attention < ActiveRecord::Base
  validates_uniqueness_of :user_id,:scope => [:target_id,:target_type],:message => "已经关注啦"

  belongs_to :user,:class_name=>"User"  ,:foreign_key=>"user_id"
  belongs_to :target,:polymorphic=>true
  acts_as_logger :log_action=>["create","destroy"],:owner_attribute=>"user",:logable=>"target"


end
