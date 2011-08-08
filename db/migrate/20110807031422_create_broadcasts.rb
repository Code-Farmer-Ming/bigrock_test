class CreateBroadcasts < ActiveRecord::Migration
  def self.up
    create_table :broadcasts do |t|
      t.integer :user_id,:null => false
      t.string :memo ,:default=>"",:limit=>64
      t.string :broadcastable_type,:null => false
      t.integer :broadcastable_id,:null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :broadcasts
  end
end
