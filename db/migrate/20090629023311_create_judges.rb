class CreateJudges < ActiveRecord::Migration
  def self.up
    create_table :judges do |t|
      t.integer :pass_id
      t.integer :user_id
      t.integer :judger_id
      t.integer :creditability_value,:default=>0
      t.integer :ability_value,:default=>0
      t.integer :eq_value,:default=>0
      t.text :description,:default=>""
      t.boolean :anonymous,:default=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :judges
  end
end
