# == Schema Information
#
# Table name: states
#
#  id   :integer       not null, primary key
#  name :string(32)    
#

class State < ActiveRecord::Base
  has_many :cities,:foreign_key=>"state_id",:class_name=>"City"
 
end
