# == Schema Information
#
# Table name: my_languages
#
#  id         :integer       not null, primary key
#  content    :string(64)    
#  user_id    :integer       
#  created_at :datetime      
#  updated_at :datetime      
#  is_current :boolean       
#

class MyLanguage < ActiveRecord::Base
  belongs_to :user,:class_name=>"User",:foreign_key=>"user_id"
  acts_as_logger :log_action=>["create"],:owner_attribute=>"user"

  #取消短语 当前记录
  def cancel_current
    update_attribute("is_current", false)
  end
  def self.current_phrase
    first(:conditions=>"is_current=#{true}")
  end
end
