# == Schema Information
#
# Table name: industry_roots
#
#  id         :integer       not null, primary key
#  name       :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class IndustryRoot < ActiveRecord::Base
  has_many :industry_seconds,:dependent => :destroy
  has_many :companies
end
