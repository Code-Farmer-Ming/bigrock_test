class AddUpAndDownToNews < ActiveRecord::Migration
  def self.up
    add_column :news, :up, :integer,:default=>0
    add_column :news, :down, :integer,:default=>0
  end

  def self.down
    remove_column :news, :up
    remove_column :news, :down
  end
end
