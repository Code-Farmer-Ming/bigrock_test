# == Schema Information
#
# Table name: company_judges
#
#  id              :integer       not null, primary key
#  company_id      :integer       
#  user_id         :integer       
#  salary_value    :integer       
#  condition_value :integer       
#  description     :text          
#  visiabled       :boolean       default(TRUE)
#  created_at      :datetime      
#  updated_at      :datetime      
#  anonymous       :boolean       
#

class CompanyJudge < ActiveRecord::Base
  #被评价的公司
  belongs_to :company ,:counter_cache=>true
  #做出评价用户
  belongs_to :judger ,:foreign_key =>"user_id",:class_name=>"User"
  
  after_create :create_judge
  before_destroy :destroy_judge
  before_update :update_judge

  named_scope :by_salary_value ,lambda { |value|
    { :conditions => { :salary_value => value } }
  }
  named_scope :by_condition_value ,lambda { |value|
    { :conditions => { :condition_value => value } }
  }
  #做评价的用户
  def judger_user
    anonymous ? User.anonymity : judger
  end
  
  def create_judge
    company.salary_value += salary_value
    company.condition_value += condition_value
    company.save!
  end
  
  def destroy_judge
    company.salary_value -= salary_value
    company.condition_value -= condition_value
    company.salary_value = 0 if company.salary_value<0
    company.condition_value = 0 if company.condition_value<0
    company.save
  end

  def update_judge
    company.salary_value+= salary_value-salary_value_was if   salary_value_changed?
    company.condition_value+= condition_value-condition_value_was if   condition_value_changed?
    company.salary_value=0 if company.salary_value<0
    company.condition_value = 0 if company.condition_value<0
    company.save
  end
 


end
