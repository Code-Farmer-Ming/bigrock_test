class RemoveIndexFromComment < ActiveRecord::Migration
  def self.up
     remove_index :comments,[:commentable_type,:commentable_id]
  end

  def self.down
    add_index :comments,[:commentable_type,:commentable_id], :unique => true
  end
end
