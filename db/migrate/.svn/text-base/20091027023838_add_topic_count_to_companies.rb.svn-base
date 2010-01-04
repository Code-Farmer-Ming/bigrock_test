class AddTopicCountToCompanies < ActiveRecord::Migration
  def self.up
    add_column :companies, :topics_count, :integer,:default=>0,:null=>false
  end

  def self.down
    remove_column :companies, :topics_count
  end
end
