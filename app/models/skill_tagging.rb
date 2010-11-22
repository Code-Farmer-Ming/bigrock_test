class SkillTagging < ActiveRecord::Base
  belongs_to :skill
  belongs_to :taggable, :polymorphic => true
  
  def after_destroy
    skill.destroy if skill and skill.skill_taggings.count == 0
  end
end
