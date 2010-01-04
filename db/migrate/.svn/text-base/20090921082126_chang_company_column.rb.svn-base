class ChangCompanyColumn < ActiveRecord::Migration
  def self.up
   
    add_column :companies, :industry_root_id, :integer
    add_column :companies, :industry_second_id, :integer
    add_column :companies, :industry_third_id, :integer
    add_column :companies, :industry_id, :integer
    add_column :companies, :company_type_id, :integer
    add_column :companies, :company_size_id, :integer
    add_column :companies, :state_id, :integer
    add_column :companies, :city_id, :integer
 
  end

  def self.down
    remove_column :companies, :industry_root_id
    remove_column :companies, :industry_second_id
    remove_column :companies, :industry_third_id
    remove_column :companies, :industry_id
    remove_column :companies, :company_type_id
    remove_column :companies, :company_size_id
    remove_column :companies, :state_id
    remove_column :companies, :city_id
  end
end
