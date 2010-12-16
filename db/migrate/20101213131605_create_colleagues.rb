class CreateColleagues < ActiveRecord::Migration
  def self.up
    create_table :colleagues do |t|
      t.integer :user_id
      t.integer :colleague_id

      t.timestamps
    end
    add_index :colleagues,[:user_id,:colleague_id], :unique => true
  end

  def self.down
    drop_table :colleagues
  end
end
