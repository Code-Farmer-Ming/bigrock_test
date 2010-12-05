class AddViewCountToNeedJob < ActiveRecord::Migration
  def self.up
    add_column :need_jobs, :view_count, :integer,:default=>0
    add_column :jobs, :skill_text, :string
  end

  def self.down
    remove_column :need_jobs, :view_count
    remove_column :jobs, :skill_text
  end
end
