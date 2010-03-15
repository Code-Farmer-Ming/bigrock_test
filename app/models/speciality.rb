# == Schema Information
#
# Table name: specialities
#
#  id          :integer       not null, primary key
#  description :string(255)   
#  resume_id   :integer       
#  created_at  :datetime      
#  updated_at  :datetime      
#  skill_id    :integer       not null
#

class Speciality < ActiveRecord::Base
  belongs_to :resume
  belongs_to  :skill

 
  attr_accessor                 :name


  def name=(name)
    self.skill = Skill.find_or_create_by_name(name)
  end
  
  def name
    self.skill ? self.skill.name : ""
  end
  
  def after_destroy
    self.skill &&  self.skill.destroy
  end

end
