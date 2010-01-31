class AddSaltToUser < ActiveRecord::Migration
  def self.up
remove_column :users, :salt
    add_column :users, :salt, :string,:limit=>255,:null=>false
    User.all.each { |item| item.create_new_salt
      item.password += 'salt'+item.salt
      item.save  }
  end

  def self.down
    remove_column :users, :salt
  end
end
