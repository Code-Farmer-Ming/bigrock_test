class AddIsCurrentToMyLanguages < ActiveRecord::Migration
  def self.up
    add_column :my_languages, :is_current, :boolean, :default=>false
  end

  def self.down
    remove_column :my_languages, :is_current
  end
end
