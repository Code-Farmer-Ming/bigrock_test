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
  validates_uniqueness_of :user_id, :scope =>[:pass_id,:judger_id],:message =>"已经评价啦"
  
  belongs_to :pass,:counter_cache => true
  #被评价用户
  belongs_to :user,:class_name=> "User",:foreign_key =>"user_id"
  #评价用户
  belongs_to :judger,:class_name=> "User",:foreign_key => "judger_id"
  #TODO: 需要添加上可以 column为空的时候 统计所有
  named_scope :judge_star, lambda { |column_name,star| { :conditions => ["#{column_name}=?",star] }
  }

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
