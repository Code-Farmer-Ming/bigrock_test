class AddFieldToJobApplicant < ActiveRecord::Migration
  def self.up
    add_column :job_applicants, :is_deleted_by_published, :boolean,:default=>false
    add_column :job_applicants, :is_deleted_by_applicant, :boolean,:default=>false
    add_column :job_applicants, :is_read, :boolean,:default=>false
  end

  def self.down
    remove_column :job_applicants, :is_read
    remove_column :job_applicants, :is_deleted_by_applicant
    remove_column :job_applicants, :is_deleted_by_published
  end
end
