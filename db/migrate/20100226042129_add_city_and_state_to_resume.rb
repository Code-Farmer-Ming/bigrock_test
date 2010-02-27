class AddCityAndStateToResume < ActiveRecord::Migration
  def self.up
    add_column :resumes, :city_id, :integer
    add_column :resumes, :state_id, :integer
    rename_column(:resumes, :phone1,:mobile)
    rename_column(:resumes, :phone2,:telephone)
    rename_column(:resumes, :website1,:blog_website)
    rename_column(:resumes, :website2,:personal_website)
  end

  def self.down
    remove_column :resumes, :state_id
    remove_column :resumes, :city_id
    rename_column(:resumes,:mobile, :phone1)
    rename_column(:resumes,:telephone, :phone2)
    rename_column(:resumes,:blog_website, :website1)
    rename_column(:resumes,:personal_website, :website2)
  end
end
