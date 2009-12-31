# == Schema Information
#
# Table name: company_types
#
#  id         :integer       not null, primary key
#  name       :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class CompanyType < ActiveRecord::Base
end
