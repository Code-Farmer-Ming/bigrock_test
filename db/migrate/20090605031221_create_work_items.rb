class CreateWorkItems < ActiveRecord::Migration
  def self.up
    create_table :work_items do |t|
      t.string :name
      t.date :begin_date
      t.date :end_date
      t.text :work_content
      t.text :work_description
      t.integer :pass_id

      t.timestamps
    end
  end

  def self.down
    drop_table :work_items
  end
end
