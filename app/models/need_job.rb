class NeedJob < ActiveRecord::Base
  named_scope :limit,lambda { |size| { :limit => size } }
 
  #发布者
  belongs_to :poster ,:class_name=>"User",:foreign_key=>"poster_id"
  belongs_to :state
  belongs_to :city 
  named_scope :limit,lambda { |size| { :limit => size } }
  named_scope :since,lambda { |day| { :conditions =>["(created_at>? or ?=0) ",day.to_i.days.ago,day.to_i]  } }
end
