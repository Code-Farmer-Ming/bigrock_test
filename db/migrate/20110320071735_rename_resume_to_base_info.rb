#将resume 改为 baseinfo 用户基本信息
class RenameResumeToBaseInfo < ActiveRecord::Migration
  def self.up
    rename_table("resumes", "base_infos")
    
    remove_column :base_infos,:name
    remove_column :base_infos,:user_name
  end

  def self.down
  end
end
