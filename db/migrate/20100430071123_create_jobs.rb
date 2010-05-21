class CreateJobs < ActiveRecord::Migration
  def self.up
    create_table :jobs do |t|
      t.string :title,:null=>false
      t.string :job_type,:null=>false
      t.text :job_description,:null=>false
      t.text :skill_description
      t.references :state,:null=>false
      t.references :city,:null=>false
      t.references :job_title
      t.datetime :end_at,:null=>false
      
      t.integer :create_user
      t.timestamps
    end
  end

  def self.down
    drop_table :jobs
  end
end
