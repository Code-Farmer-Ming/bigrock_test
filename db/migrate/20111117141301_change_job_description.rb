class ChangeJobDescription < ActiveRecord::Migration
  def self.up
  
    rename_column :jobs,:job_description,:description
  end

  def self.down
    rename_column :jobs,:description,:job_description
  end
end
