# == Schema Information
#
# Table name: user_tags
#
#  id         :integer       not null, primary key
#  user_id    :integer       not null
#  tagging_id :integer       not null
#  created_at :datetime      
#  updated_at :datetime      
#

class UserTag < ActiveRecord::Base
  belongs_to :user,:class_name=>"User",:foreign_key=>"user_id"
  belongs_to :tagging,:counter_cache=>true

  def after_destroy
    if tagging and tagging.user_tags.count.zero?
      tagging.destroy 
    end
  end
end
