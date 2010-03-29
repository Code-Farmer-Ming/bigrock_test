class ChangeMemeber < ActiveRecord::Migration
  def self.up
    
    Member.all.each { |item|
      item.member_type = item.member_type.humanize
      item.save  }
    change_column_default(:members,"member_type","Normal")
    rename_column(:members, "member_type", "type")
  end

  def self.down
    rename_column(:members, "type", "member_type")
  end
end
