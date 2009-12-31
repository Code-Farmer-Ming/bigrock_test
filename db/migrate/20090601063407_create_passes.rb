class CreatePasses < ActiveRecord::Migration
  def self.up
    create_table :passes do |t|
      t.integer :company_id
      t.integer :resume_id
      t.integer :user_id
      t.string :title
      t.string :department
      t.date :begin_date
      t.date :end_date
      t.text :work_description
      t.boolean :is_current,:default=>false
      #评价值
      t.integer :creditability_value,:default=>0
      t.integer :ability_value,:default=>0
      t.integer :eq_value,:default=>0
      t.timestamps
    end
  end

  def self.down
    drop_table :passes
  end
end
