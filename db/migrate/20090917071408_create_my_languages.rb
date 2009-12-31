class CreateMyLanguages < ActiveRecord::Migration
  def self.up
    create_table :my_languages do |t|
      t.string :content,:limit=>64
      t.integer :user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :my_languages
  end
end
