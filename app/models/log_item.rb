# == Schema Information
#
# Table name: log_items
#
#  id                :integer       not null, primary key
#  logable_type      :string(255)   
#  logable_id        :integer       
#  log_type          :string(255)   
#  changes           :string(255)   
#  owner_id          :integer       
#  owner_type        :string(255)   
#  created_at        :datetime      
#  updated_at        :datetime      
#  operation         :string(255)   
#  origin_value_type :string(255)   
#  origin_value_id   :integer       
#

class LogItem < ActiveRecord::Base
  belongs_to :owner ,:polymorphic => true
  belongs_to :logable,:polymorphic=>true
  belongs_to :origin_value,:polymorphic=>true
  serialize :changes

  def self.per_page
    15
  end
  
end
