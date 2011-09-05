# == Schema Information
#
# Table name: log_items
#
#  id           :integer       not null, primary key
#  logable_type :string(255)   
#  logable_id   :integer       
#  log_type     :string(255)   
#  operation    :string(255)   
#  changes      :string(255)   
#  owner_id     :integer       
#  owner_type   :string(255)   
#  created_at   :datetime      
#  updated_at   :datetime      
#

class LogItem < ActiveRecord::Base
  belongs_to :owner ,:polymorphic => true
  belongs_to :logable,:polymorphic=>true

  serialize :changes

  def self.per_page
    15
  end
  
end
