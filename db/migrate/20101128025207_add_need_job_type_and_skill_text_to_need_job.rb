class AddNeedJobTypeAndSkillTextToNeedJob < ActiveRecord::Migration
  def self.up
    add_column :need_jobs, :type_id, :integer,:null=>false,:default=>0
    add_column :need_jobs, :skill_text, :string
  end

  def self.down
    remove_column :need_jobs, :skill_text
    remove_column :need_jobs, :type_id
  end
end
