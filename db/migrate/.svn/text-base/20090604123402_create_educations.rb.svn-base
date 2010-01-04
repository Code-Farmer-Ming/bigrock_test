class CreateEducations < ActiveRecord::Migration
  def self.up
    create_table :educations do |t|
      t.string :school_name
      t.date :begin_date
      t.date :end_date
      t.text :description
      t.integer:resume_id
      t.string :degree
      t.string :major
      t.timestamps
    end
  end

  def self.down
    drop_table :educations
  end
end
