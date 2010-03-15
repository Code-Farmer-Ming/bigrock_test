# == Schema Information
#
# Table name: schools
#
#  id         :integer       not null, primary key
#  name       :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

class School < ActiveRecord::Base
    has_many :educations

  def before_destroy
    self.educations.count==0
  end
end
