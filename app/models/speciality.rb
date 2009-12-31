# == Schema Information
#
# Table name: specialities
#
#  id          :integer       not null, primary key
#  name        :string(255)   
#  description :string(255)   
#  resume_id   :integer       
#  created_at  :datetime      
#  updated_at  :datetime      
#

class Speciality < ActiveRecord::Base
  belongs_to :resume
  validates_uniqueness_of     :name
  validates_presence_of :name

end
