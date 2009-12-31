class CreateUserTags < ActiveRecord::Migration
  def self.up
    create_table :user_tags do |t|
      t.integer :user_id,:null => false
      t.integer :tagging_id,:null => false

      t.timestamps
    end
  end

  def self.down
    drop_table :user_tags
  end
end
