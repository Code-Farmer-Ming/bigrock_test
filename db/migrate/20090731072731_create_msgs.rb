class CreateMsgs < ActiveRecord::Migration
  def self.up
    create_table :msgs do |t|
      t.integer :sender_id,:null => false
      t.integer :sendee_id,:null => false
      t.string :title,:limit=>128,:null => false
      t.string :content,:null => false
      t.boolean :is_check,:default=>false
      t.boolean :sender_stop,:default=>false
      t.boolean :sendee_stop,:default=>false
      t.timestamps
    end
  end

  def self.down
    drop_table :msgs
  end
end
