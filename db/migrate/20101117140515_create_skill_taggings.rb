class CreateSkillTaggings < ActiveRecord::Migration
  def self.up
    create_table :skill_taggings do |t|
      t.integer :id
      t.integer :skill_id
      t.integer :taggable_id
      t.string :taggable_type
      t.timestamps
    end
    add_index :skill_taggings, [:skill_id, :taggable_id, :taggable_type], :unique => true,:name=>"skill_taggings_index"
  end

  def self.down
    drop_table :skill_taggings
  end
end
