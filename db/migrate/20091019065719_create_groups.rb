class CreateGroups < ActiveRecord::Migration
  def self.up
    create_table :groups do |t|
      t.string :name,:null=>false
      t.text :description,:null=>false
      t.integer :group_type,:null=>false
      t.string :join_type,:null=>false,:limit=>16
      t.integer :create_user_id,:null=>false
      t.integer :members_count,:default=>0
      t.integer :topics_count,:default=>0

      t.timestamps
    end
  end

  def self.down
    drop_table :groups
  end
end
