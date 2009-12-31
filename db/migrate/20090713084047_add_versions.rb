class AddVersions < ActiveRecord::Migration
  def self.up
    
    Company.create_versioned_table
  end

  def self.down
    Company.drop_versioned_table
  end
end
