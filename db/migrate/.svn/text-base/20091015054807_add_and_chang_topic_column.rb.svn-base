class AddAndChangTopicColumn < ActiveRecord::Migration
  def self.up
    rename_column(:topics, :topic_comment_count,:comments_count)
    add_column :topics,:top_level,:boolean,:default=>false
    add_column :topics,:can_comment,:boolean,:default=>true
    add_column :topics,:last_comment_user_id,:integer
    add_column :topics,:last_comment_datetime,:datetime
  end

  def self.down
    remove_column :topics,:can_comment
    remove_column :topics,:last_comment_user_id
    remove_column :topics,:top_level
    remove_column :topics,:last_comment_datetime
    rename_column(:topics,:comments_count ,:topic_comment_count)
  end
end
