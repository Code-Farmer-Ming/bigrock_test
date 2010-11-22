# == Schema Information
#
# Table name: states
#
#  id   :integer       not null, primary key
#  name :string(32)    
#

class State < ActiveRecord::Base
  has_many :cities,:foreign_key=>"state_id",:class_name=>"City"
  # [name,id]的数组结构
  def self.to_select_option(blank=nil)
    (blank ? [[blank,-1]] :[]) + all(:order=>:id).collect { |item| [item.name,item.id]  }
  end
  #包含城市的 二维数组 结构 [id,city]
  def self.to_select_option_with_city(state_blank=nil,city_blank=nil)
    (state_blank ? [[-1,[[-1,state_blank]]]] :[])+all.collect {|p| [ p.id,  (city_blank ? [[-1,city_blank]] :[])+p.cities.all.collect{|q| [q.id,q.name] } ] }
  end
end
