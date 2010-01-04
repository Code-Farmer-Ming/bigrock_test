class CreateNewsComments < ActiveRecord::Migration
  def self.up
    create_table :news_comments do |t|
      t.integer :news_id,:null=>false
      t.integer :up,:default=>0
      t.integer :down,:default=>0
      t.string :content,:null=>false
      t.integer :user_id,:null=>false

      t.timestamps
    end
  end

  def self.down
    drop_table :news_comments
  end
end
