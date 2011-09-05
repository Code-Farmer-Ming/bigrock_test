class ChangUserTitleToSignature < ActiveRecord::Migration
  def self.up
    rename_column :users,:title,:signature
    change_column :users,:signature,:string,:limit=>32
  end

  def self.down
    rename_column :users,:signature,:title
  end
end
