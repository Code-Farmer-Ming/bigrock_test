# == Schema Information
#
# Table name: cities
#
#  id         :integer       not null, primary key
#  state_id   :integer       
#  name       :string(255)   
#  user_id    :integer       
#  created_at :datetime      
#  updated_at :datetime      
#

class City < ActiveRecord::Base

  belongs_to :state,:foreign_key=>"state_id",:class_name=>"State"
end
