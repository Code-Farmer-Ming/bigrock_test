# == Schema Information
#
# Table name: judges
#
#  id                  :integer       not null, primary key
#  pass_id             :integer       
#  user_id             :integer       
#  judger_id           :integer       
#  creditability_value :integer       default(0)
#  ability_value       :integer       default(0)
#  eq_value            :integer       default(0)
#  description         :text          
#  visiabled           :boolean       default(TRUE)
#  created_at          :datetime      
#  updated_at          :datetime      
#  anonymous           :boolean       default(TRUE)
#

class Judge < ActiveRecord::Base
  belongs_to :pass,:counter_cache => true
  #被评价用户
  belongs_to :user,:class_name=> "User",:foreign_key =>"user_id"
  #评价用户
  belongs_to :judger,:class_name=> "User",:foreign_key => "judger_id"
  def before_create
    pass.ability_value += ability_value
    pass.eq_value += eq_value
    pass.creditability_value += creditability_value
    pass.save
  end
  
  def before_update
    pass.ability_value += ability_value-ability_value_was if ability_value_changed?
    pass.eq_value += eq_value - eq_value_was if eq_value_changed?
    pass.creditability_value += creditability_value - creditability_value_was if creditability_value_changed?
    
    pass.ability_value =0 if  pass.ability_value <0
    pass.eq_value = 0 if   pass.eq_value<0
    pass.creditability_value = 0 if  pass.creditability_value <0
    pass.save
  end

  def before_destroy
    pass.ability_value -= ability_value
    pass.eq_value -= eq_value
    pass.creditability_value -= creditability_value
    pass.ability_value =0 if  pass.ability_value <0
    pass.eq_value = 0 if   pass.eq_value<0
    pass.creditability_value = 0 if  pass.creditability_value <0
    pass.save
  end

end
