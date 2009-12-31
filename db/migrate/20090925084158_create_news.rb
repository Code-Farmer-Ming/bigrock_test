class CreateNews < ActiveRecord::Migration
  def self.up
    create_table :news do |t|
      t.integer :company_id,:null=>false
      t.string :title,:limit=>64,:null=>false
      t.text :content,:null=>false
      t.integer :create_user_id,:null=>false
      t.integer :last_edit_user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :news
  end
end
