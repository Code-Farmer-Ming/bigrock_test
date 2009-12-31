# == Schema Information
#
# Table name: industry_seconds
#
#  id               :integer       not null, primary key
#  industry_root_id :integer       
#  name             :string(255)   
#  created_at       :datetime      
#  updated_at       :datetime      
#

class IndustrySecond < ActiveRecord::Base
  has_many :industry_thirds,:dependent => :destroy
  has_many :companies

  belongs_to :industry_root
end
