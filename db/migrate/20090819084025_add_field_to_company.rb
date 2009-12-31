class AddFieldToCompany < ActiveRecord::Migration
  def self.up
    add_column :companies, :salary_value, :integer,:default=>0
    add_column :companies, :condition_value, :integer,:default=>0
    add_column :companies, :company_judges_count,:integer,:default=>0
    add_column :companies, :fax,:string
    add_column :companies, :phone,:string
    add_column :companies, :last_edit_user_id, :integer
  end

  def self.down
    remove_column :companies, :condition_value
    remove_column :companies, :salary_value
    remove_column :companies, :company_judges_count
    remove_column :companies, :fax
    remove_column :companies, :phone
    remove_column :companies, :last_edit_user_id
  end
end
