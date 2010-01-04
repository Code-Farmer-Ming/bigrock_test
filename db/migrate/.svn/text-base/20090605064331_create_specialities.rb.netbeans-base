class CreateSpecialities < ActiveRecord::Migration
  def self.up
    create_table :specialities do |t|
      t.string :name
      t.string :description
      t.integer :resume_id

      t.timestamps
    end
  end

  def self.down
    drop_table :specialities
  end
end
