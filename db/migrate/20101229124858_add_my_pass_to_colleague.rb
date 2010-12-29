class AddMyPassToColleague < ActiveRecord::Migration
  def self.up
    add_column :colleagues, :my_pass_id, :integer
    rename_column :colleagues ,:pass_id,:colleague_pass_id
    remove_index :colleagues,[:user_id,:colleague_id]

  end

  def self.down
    remove_column :colleagues, :my_pass_id
    rename_column :colleagues ,:colleague_pass_id,:pass_id
  end
end
