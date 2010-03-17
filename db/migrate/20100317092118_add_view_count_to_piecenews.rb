class AddViewCountToPiecenews < ActiveRecord::Migration
  def self.up
    add_column :news, :view_count, :integer,:default=>0
  end

  def self.down
    remove_column :news, :view_count
  end
end
