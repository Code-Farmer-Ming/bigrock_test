# == Schema Information
#
# Table name: requisitions
#
#  id             :integer       not null, primary key
#  applicant_id   :integer       
#  respondent_id  :integer       
#  type           :string(255)   
#  memo           :string(255)   
#  created_at     :datetime      
#  updated_at     :datetime      
#  applicant_type :string(255)   
#

class Requisition < ActiveRecord::Base
  #申请用户
  belongs_to :applicant ,:foreign_key=>"applicant_id",:polymorphic =>true
  #被申请的用户
  belongs_to :respondent ,:class_name=>"User" ,:foreign_key=>"respondent_id"


end
