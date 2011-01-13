# == Schema Information
#
# Table name: industries
#
#  id   :integer       not null, primary key
#  name :string(255)   
#

class Industry < ActiveRecord::Base
  has_many :companies
  
  #返回数据的 select标签 需要的数据格式
  def self.select_options
    self.all.collect {|p| [ p.name, p.id ] }
  end
end
