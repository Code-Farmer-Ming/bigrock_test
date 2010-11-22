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

  def self.to_select_option(state_id=nil,blank=nil)
    result =  find_all_by_state_id(state_id ? state_id : 1)
    (blank ? [[blank,-1]] :[]) + result.collect { |item| [item.name,item.id]  }
  end
end
