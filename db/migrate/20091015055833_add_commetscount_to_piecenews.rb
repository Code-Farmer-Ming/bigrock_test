class AddCommetscountToPiecenews < ActiveRecord::Migration
  def self.up
    add_column :news, :comments_count, :integer,:default=>0
  end

  def self.down
    remove_column :news, :comments_count
  end
end
