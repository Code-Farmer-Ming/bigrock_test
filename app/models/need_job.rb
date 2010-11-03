class NeedJob < ActiveRecord::Base
  named_scope :limit,lambda { |size| { :limit => size } }
 
  #发布者
  belongs_to :poster ,:class_name=>"User",:foreign_key=>"poster_id"
  belongs_to :state
  belongs_to :city 
  
end
