# == Schema Information
#
# Table name: educations
#
#  id          :integer       not null, primary key
#  school_name :string(255)   
#  begin_date  :date          
#  end_date    :date          
#  description :text          
#  resume_id   :integer       
#  degree      :string(255)   
#  major       :string(255)   
#  created_at  :datetime      
#  updated_at  :datetime      
#

class Education < ActiveRecord::Base
  belongs_to:resume
  acts_as_logger :log_action=>["create"],:owner_attribute=>"resume.user",:log_type=>"resume"
  validates_uniqueness_of     :school_name
  validates_presence_of :school_name

end
