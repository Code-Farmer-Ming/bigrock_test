class AddPosterToUserBroadcast < ActiveRecord::Migration
  def self.up
    add_column :user_broadcasts, :poster_id, :integer
  end

  def self.down
    remove_column :user_broadcasts, :poster_id
  end
end
