# == Schema Information
#
# Table name: work_items
#
#  id               :integer       not null, primary key
#  name             :string(255)   
#  begin_date       :date          
#  end_date         :date          
#  work_content     :text          
#  work_description :text          
#  pass_id          :integer       
#  created_at       :datetime      
#  updated_at       :datetime      
#

class WorkItem < ActiveRecord::Base
  belongs_to:pass
  def user
    pass.user
  end

end
