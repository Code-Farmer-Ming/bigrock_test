class CreateJobApplicants < ActiveRecord::Migration
  def self.up
    create_table :job_applicants do |t|
      t.references :job,:null=>false
      t.integer :applicant_id,:null=>false
      t.integer :recommend_id
      t.string :memo

      t.timestamps
    end
  end

  def self.down
    drop_table :job_applicants
  end
end
