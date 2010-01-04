class CreateRecommends < ActiveRecord::Migration
  def self.up
    create_table :recommends do |t|
      t.integer :user_id,:null => false
      t.string :memo ,:default=>"",:limit=>64
      t.string :recommendable_type,:null => false
      t.integer :recommendable_id,:null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :recommends
  end
end
