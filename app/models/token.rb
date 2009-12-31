# == Schema Information
#
# Table name: tokens
#
#  id         :integer       not null, primary key
#  user_id    :integer       
#  action     :string(255)   
#  value      :string(255)   
#  created_at :datetime      
#  updated_at :datetime      
#

require 'rails_generator/secret_key_generator'
class Token < ActiveRecord::Base
  #重设密码
  ACTION_RECOVERY="recovery"

  belongs_to:user,:class_name=> "User"
  
  validates_uniqueness_of :value
  
  def before_create
    self.value = Token.generate_token_value
  end
  private
  def self.generate_token_value
    s = ActiveSupport::SecureRandom.hex(64)
    s[0, 40]
  end
end
