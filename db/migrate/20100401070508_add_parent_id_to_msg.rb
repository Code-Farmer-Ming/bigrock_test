class AddParentIdToMsg < ActiveRecord::Migration
  def self.up
    add_column :msgs, :parent_id, :integer,:default =>0
  end

  def self.down
    remove_column :msgs, :parent_id
  end
end
