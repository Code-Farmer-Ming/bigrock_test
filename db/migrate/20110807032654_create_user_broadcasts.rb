class CreateUserBroadcasts < ActiveRecord::Migration
  def self.up
    create_table :user_broadcasts do |t|
      t.integer :user_id
      t.integer :broadcast_id
      t.boolean :is_read,:default=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :user_broadcasts
  end
end
