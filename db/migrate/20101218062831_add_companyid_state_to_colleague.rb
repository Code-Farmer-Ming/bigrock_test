class AddCompanyidStateToColleague < ActiveRecord::Migration
  def self.up
    add_column :colleagues, :company_id, :integer
    add_column :colleagues, :pass_id, :integer
    add_column :colleagues, :state, :string,:default=>Colleague::STATES[0]
    add_column :colleagues, :is_judge,:boolean,:default=>false
  end

  def self.down
    remove_column :colleagues, :company_id
    remove_column :colleagues, :state
    remove_column :colleagues, :pass_id
    remove_column :colleagues,:is_judge
  end
end
