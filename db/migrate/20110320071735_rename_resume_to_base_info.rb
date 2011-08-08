#将resume 改为 baseinfo 用户基本信息
class RenameResumeToBaseInfo < ActiveRecord::Migration
  def self.up
 
    rename_table("resumes", "base_infos")
    remove_column :base_infos,:name
    remove_column :base_infos,:user_name
    remove_column :base_infos,:is_current
    remove_column :base_infos,:type_name
  end

  def self.down
    rename_table("base_infos", "resumes")
    add_column :base_infos,:name,:string
    add_column :base_infos,:user_name,:string
    add_column :base_infos,:is_current,:string
    add_column :base_infos,:type_name,:string
  end
end
