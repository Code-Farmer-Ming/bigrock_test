# == Schema Information
#
# Table name: skills
#
#  id         :integer       not null, primary key
#  name       :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class Skill < ActiveRecord::Base
  has_many :specialities
 
  def before_destroy
    self.specialities.count==0
  end
end
