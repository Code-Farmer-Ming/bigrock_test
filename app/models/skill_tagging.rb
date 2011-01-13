# == Schema Information
#
# Table name: skill_taggings
#
#  id            :integer       not null, primary key
#  skill_id      :integer       
#  taggable_id   :integer       
#  taggable_type :string(255)   
#  created_at    :datetime      
#  updated_at    :datetime      
#

class SkillTagging < ActiveRecord::Base
  belongs_to :skill
  belongs_to :taggable, :polymorphic => true
  
  def after_destroy
    skill.destroy if skill and skill.skill_taggings.count == 0
  end
end
