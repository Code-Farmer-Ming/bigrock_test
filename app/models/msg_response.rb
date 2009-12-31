# == Schema Information
#
# Table name: msg_responses
#
#  id         :integer       not null, primary key
#  msg_id     :integer       
#  sender_id  :integer       
#  content    :string(255)   
#  is_check   :boolean       
#  created_at :datetime      
#  updated_at :datetime      
#

class MsgResponse < ActiveRecord::Base
  belongs_to :msg
  belongs_to :sender,:class_name=>"User",:foreign_key=>"sender_id"
end
