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
  #重设密码的token
  named_scope :recovery,:conditions=>["action=?",ACTION_RECOVERY]
  
  validates_uniqueness_of :value
  #创建 一个 重设密码 token
  def self.new_recovery(user)
    Token.recovery.destroy_all(:user_id=>user)
    Token.new(:user=>user,:action=>ACTION_RECOVERY)
  end
  def before_create
    self.value = Token.generate_token_value
  end
  private
  def self.generate_token_value
    s = ActiveSupport::SecureRandom.hex(64)
    s[0, 40]
  end
end
