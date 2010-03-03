class School < ActiveRecord::Base
    has_many :educations

  def before_destroy
    self.educations.count==0
  end
end
