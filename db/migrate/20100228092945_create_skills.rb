class CreateSkills < ActiveRecord::Migration
  def self.up
    create_table :skills do |t|
      t.string :name
      t.timestamps 
    end
    add_index :skills,:name
    add_column  :specialities,:skill_id,:integer,:null=>false
    remove_column(:specialities, :name)
  end

  def self.down
    add_column(:specialities, :name)
    remove_column  :specialities,:skill_id
    drop_table :skills
  end
end
