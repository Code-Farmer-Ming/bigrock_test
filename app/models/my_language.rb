# == Schema Information
#
# Table name: my_languages
#
#  id         :integer       not null, primary key
#  content    :string(64)    
#  user_id    :integer       
#  created_at :datetime      
#  updated_at :datetime      
#  is_current :boolean       default(TRUE)
#

class MyLanguage < ActiveRecord::Base
  belongs_to :user,:class_name=>"User",:foreign_key=>"user_id"
  acts_as_logger :log_action=>["create"],:owner_attribute=>"user"

  #取消当前 
  def cancel_current
    update_attribute("is_current", false)
  end
  def self.current_language
    first(:conditions=>"is_current=#{true}")
  end
end
