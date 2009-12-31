class CreateLogItems < ActiveRecord::Migration
  def self.up
    create_table :log_items do |t|
      t.string :logable_type
      t.integer :logable_id
      t.string :log_type
      t.string :operation
      t.string :changes
      t.integer :owner_id
      t.string :owner_type

      t.timestamps
    end
  end

  def self.down
    drop_table :log_items
  end
end
