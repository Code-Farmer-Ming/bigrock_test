# == Schema Information
#
# Table name: friends
#
#  id          :integer       not null, primary key
#  user_id     :integer       
#  friend_id   :integer       
#  friend_type :integer       
#  created_at  :datetime      
#  updated_at  :datetime      
#

class Friend < ActiveRecord::Base
  belongs_to :user,:class_name=>"User",:foreign_key=>"user_id"
  belongs_to :friend,:class_name=>"User",:foreign_key=>"friend_id"
  acts_as_logger :log_action=>["create","destroy"],:owner_attribute=>"user",:logable=>"friend"

  def self.per_page
    20
  end
end


