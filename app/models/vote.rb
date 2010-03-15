# == Schema Information
#
# Table name: votes
#
#  id         :integer       not null, primary key
#  owner_id   :integer       
#  owner_type :string(255)   
#  user_id    :integer       
#  value      :integer       default(0)
#  created_at :datetime      
#  updated_at :datetime      
#

class Vote < ActiveRecord::Base
  belongs_to :user
  belongs_to :owner,:polymorphic => true;
end
