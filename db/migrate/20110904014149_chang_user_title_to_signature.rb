class ChangUserTitleToSignature < ActiveRecord::Migration
  def self.up
    change_column :users,:title,:string,:limit=>32
    rename_column :users,:title,:signature
  end

  def self.down
    rename_column :users,:signature,:title
  end
end
