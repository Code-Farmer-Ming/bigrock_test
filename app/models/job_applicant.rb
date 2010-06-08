class JobApplicant < ActiveRecord::Base
  belongs_to :job,:counter_cache=>"applicants_count"
  belongs_to :applicant_user,:class_name=>"User",:foreign_key=>"applicant_id"
  belongs_to :recommend_user,:class_name=>"User",:foreign_key=>"recommend_id"
  #申请者 用 分隔
  attr_accessor :applicant_user_ids
end
