class AddCompanyIdToJob < ActiveRecord::Migration
  def self.up
    add_column :jobs,:company_id,:integer
    add_column :jobs,:view_count,:integer,:default=>0
    add_column :jobs,:applicants_count,:integer,:default=>0
    #companies 表 加上 job 的计数
    add_column :companies,:jobs_count,:integer,:default=>0

    add_column :jobs,:comments_count,:integer,:default=>0
    rename_column(:jobs, "create_user", "create_user_id")
    rename_column(:jobs, "job_type", "type_id")
  end

  def self.down
    remove_column :jobs,:company_id
    remove_column :jobs,:view_count
    remove_column :jobs,:applicants_count
    remove_column :jobs,:comments_count
    rename_column(:jobs, "type_id","job_type")
    rename_column(:jobs ,"create_user_id", "create_user")
  end
end
