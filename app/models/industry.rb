# == Schema Information
#
# Table name: industries
#
#  id                :integer       not null, primary key
#  industry_third_id :integer       
#  name              :string(255)   
#  created_at        :datetime      
#  updated_at        :datetime      
#

class Industry < ActiveRecord::Base
  has_many :companies
end
