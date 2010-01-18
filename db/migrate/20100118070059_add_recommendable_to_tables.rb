class AddRecommendableToTables < ActiveRecord::Migration
  def self.up
    add_column :groups, :recommends_count, :integer,:default=>0
    add_column :news, :recommends_count, :integer,:default=>0
    add_column :topics, :recommends_count, :integer,:default=>0
  end

  def self.down
    remove_column :groups, :recommends_count
    remove_column :news, :recommends_count
    remove_column :topics, :recommends_count
  end
end
