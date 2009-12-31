class CreateMembers < ActiveRecord::Migration
  def self.up
    create_table :members do |t|
      t.integer :group_id,:null=>false
      t.integer :user_id,:null=>false
      t.string :member_type,:limit=>18,:default=>Member::MEMBER_TYPES[2] #默认普通用户

      t.timestamps
    end
  end

  def self.down
    drop_table :members
  end
end
