class RenameGroupTypeToGroupTypeIdToGroups < ActiveRecord::Migration
  def self.up
    rename_column(:groups, :group_type,:group_type_id)
  end

  def self.down
    rename_column(:groups,:group_type_id, :group_type)
  end
end
