# == Schema Information
#
# Table name: job_titles
#
#  id         :integer       not null, primary key
#  company_id :integer       
#  name       :string(255)   not null
#  created_at :datetime      
#  updated_at :datetime      
#

class JobTitle < ActiveRecord::Base
  has_many :passes
  has_many :jobs
  
  def before_destroy
    self.passes.count==0 && self.jobs.count==0
  end
end
