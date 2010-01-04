class AddParentIdToUserRegisterInfo < ActiveRecord::Migration
  def self.up
    add_column :user_register_infos, :parent_id, :integer,:default=>0,:null=>false
    rename_column(:user_register_infos, :IsActive,:is_active)
  end

  def self.down
    remove_column :user_register_infos, :parent_id
    rename_column(:user_register_infos,:is_active, :IsActive)
  end
end
