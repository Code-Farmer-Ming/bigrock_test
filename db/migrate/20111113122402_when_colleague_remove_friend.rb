
class WhenColleagueRemoveFriend < ActiveRecord::Migration
  def self.up
    User.real_users.each do |user|
      user.colleague_users do |colleague|
        user.friend_users.delete(colleague)
        colleague.friend_users.delete(user)
        colleague.my_add_friend_application_users.delete(user)
        user.my_add_friend_application_users.delete(colleague)
      end
    end
  end

  def self.down
  end
end
