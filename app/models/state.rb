# == Schema Information
#
# Table name: states
#
#  id         :integer       not null, primary key
#  name       :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class State < ActiveRecord::Base
  has_many :cities,:foreign_key=>"state_id",:class_name=>"City"
end
