class CreateCompanies < ActiveRecord::Migration
  def self.up
    create_table :companies do |t|
      t.string :name,:default=>""
      t.text :description,:default=>""
      t.string :website,:default=>""
      t.string :address,:default=>""
      t.integer :create_user_id

      t.timestamps
    end
  end

  def self.down
    drop_table :companies
  end
end
