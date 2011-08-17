# == Schema Information
#
# Table name: educations
#
#  id          :integer       not null, primary key
#  begin_date  :date          
#  end_date    :date          
#  description :text          
#  degree      :string(255)   
#  major       :string(255)   
#  created_at  :datetime      
#  updated_at  :datetime      
#  school_id   :integer       not null
#  user_id     :integer       
#

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
  validates_uniqueness_of :user_id, :scope =>:school_id,:message =>"已经有这个学校啦"
  
  belongs_to:resume
  belongs_to :user

  acts_as_logger :log_action=>["create"],:owner_attribute=>"user",:log_type=>"resume"
 
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
