# == Schema Information
#
# Table name: company_sizes
#
#  id         :integer       not null, primary key
#  name       :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class CompanySize < ActiveRecord::Base
  #返回数据的 select标签 需要的数据格式
  def self.select_options
    self.all.collect {|p| [ p.name, p.id ] }
  end
end
