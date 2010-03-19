class AddViewCountToPiecenews < ActiveRecord::Migration
  def self.up
    add_column :news, :view_count, :integer,:default=>0
    add_column  :news,:last_edit_at,:datetime
  end

  def self.down
    remove_column :news, :view_count
    remove_column :news, :last_edit_at
  end
end
