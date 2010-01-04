class RenameNewsCommentAndChanggingColumn < ActiveRecord::Migration
  def self.up
    rename_table('news_comments', 'comments')
    rename_column(:comments, :news_id,:commentable_id)
    add_column :comments,:commentable_type,:string
  end

  def self.down
    rename_table('comments', 'news_comments')
    rename_column(:news_comments,:commentable_id, :news_id)
    remove_column :news_comments,:commentable_type
  end
end
