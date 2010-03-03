class CreateSchools < ActiveRecord::Migration
  def self.up
    create_table :schools do |t|
      t.string :name
      t.timestamps
    end
    add_index :schools,:name
    add_column  :educations,:school_id,:integer,:null=>false
    remove_column(:educations, :school_name)
  end

  def self.down
    drop_table :schools
    remove_column  :educations,:school_id
    add_column(:educations, :school_name,:string)
  end
end
