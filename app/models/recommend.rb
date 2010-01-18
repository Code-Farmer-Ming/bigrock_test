# == Schema Information
#
# Table name: recommends
#
#  id                 :integer       not null, primary key
#  user_id            :integer       not null
#  memo               :string(255)   default("")
#  recommendable_type :string(255)   default(""), not null
#  recommendable_id   :integer       not null
#  created_at         :datetime      
#  updated_at         :datetime      
#

class Recommend < ActiveRecord::Base
  acts_as_logger :log_action=>["create"],:owner_attribute=>"user"
#  acts_as_logger :log_action=>["create"],:owner_attribute=>"company",:log_type=>"recommend",:logable=>"user"
  
  belongs_to :user ,:class_name=>"User",:foreign_key=>"user_id"
  belongs_to :recommendable ,:polymorphic => true,:counter_cache=>true 
end
