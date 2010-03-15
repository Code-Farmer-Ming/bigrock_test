# == Schema Information
#
# Table name: educations
#
#  id          :integer       not null, primary key
#  begin_date  :date          
#  end_date    :date          
#  description :text          
#  resume_id   :integer       
#  degree      :string(255)   
#  major       :string(255)   
#  created_at  :datetime      
#  updated_at  :datetime      
#  school_id   :integer       not null
#

class Education < ActiveRecord::Base
  belongs_to:resume
  acts_as_logger :log_action=>["create"],:owner_attribute=>"resume.user",:log_type=>"resume"
 
  belongs_to  :school


  attr_accessor                 :school_name


  def school_name=(name)
    self.school = School.find_or_create_by_name(name)
  end

  def school_name
    self.school ? self.school.name : ""
  end

  def after_destroy
    self.school && self.school.destroy
  end

end
