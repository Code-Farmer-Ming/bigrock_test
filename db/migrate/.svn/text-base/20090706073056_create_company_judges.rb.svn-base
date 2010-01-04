class CreateCompanyJudges < ActiveRecord::Migration
  def self.up
    create_table :company_judges do |t|
      t.integer :company_id
      t.integer :user_id
      t.integer :salary_value,:default=>0
      t.integer :condition_value,:default=>0
      t.text :description,:default=>""
      t.boolean :anonymous,:default=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :company_judges
  end
end
