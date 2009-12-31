class AddApplyFriendAuthToUserSettings < ActiveRecord::Migration
  def self.up
    add_column :user_settings, :apply_friend_auth, :string,:default=>UserSetting::APPLY_FRIEND_TYPES[0]
 

  end

  def self.down
     remove_column :user_settings, :apply_friend_auth
  end
end
