class Skill < ActiveRecord::Base
  has_many :specialities
 
  def before_destroy
    self.specialities.count==0
  end
end
