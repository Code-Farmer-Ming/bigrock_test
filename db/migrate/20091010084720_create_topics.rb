class CreateTopics < ActiveRecord::Migration
  def self.up
    create_table :topics do |t|
      t.integer :owner_id,:null=>false
      t.string :owner_type,:null=>false
      t.integer :author_id,:null=>false
      t.string :title ,:limit=>128
      t.text :content,:null=>false
      t.integer :up,:default=>0
      t.integer :down,:default=>0
      t.integer :topic_comment_count,:default=>0
      t.integer :view_count,:default=>0

      t.timestamps
    end
  end

  def self.down
    drop_table :topics
  end
end
