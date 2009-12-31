# == Schema Information
#
# Table name: industry_thirds
#
#  id                 :integer       not null, primary key
#  industry_second_id :integer       
#  name               :string(255)   
#  created_at         :datetime      
#  updated_at         :datetime      
#

class IndustryThird < ActiveRecord::Base
  has_many :industries,:dependent => :destroy
  has_many :companies

  belongs_to :industry_second
end
