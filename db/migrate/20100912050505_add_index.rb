class AddIndex < ActiveRecord::Migration
  def self.up
    add_index :user_settings,:user_id, :unique => true
    add_index :topics,[:owner_type,:owner_id]
    add_index :attachments,[:type,:master_id], :unique => true
    add_index :comments,[:commentable_type,:commentable_id], :unique => true
  end

  def self.down
    remove_index :user_settings,:user_id
    remove_index :topics,[:owner_type,:owner_id]
    remove_index :attachments,[:type,:master_id]
    remove_index :comments,[:commentable_type,:commentable_id]
  end
end
