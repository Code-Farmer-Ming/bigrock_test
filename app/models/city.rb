# == Schema Information
#
# Table name: cities
#
#  id       :integer       not null, primary key
#  state_id :integer       not null
#  name     :string(32)    
#

class City < ActiveRecord::Base

  belongs_to :state,:foreign_key=>"state_id",:class_name=>"State"
end
