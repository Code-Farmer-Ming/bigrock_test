
class WhenColleagueRemoveFriend < ActiveRecord::Migration
  def self.up
    User.real_users.each do |user|
      user.colleague_users.each do |colleague|
        user.friend_users.delete(colleague)
        colleague.friend_users.delete(user)
        colleague.my_add_friend_application_users.delete(user)
        user.my_add_friend_application_users.delete(colleague)
      end
    end
    User.real_users.each do |user|
      user.friend_users.each do |friend|
        if (!friend.friend_users.exists?(user))
          friend.friend_users << user
          if  friend.my_follow_users.exists?(user)
            friend.add_attention(user)
          end
        end
      end
    end
    
    LogItem.find_all_by_log_type_and_logable_type("Attention","User").each {|item| item.delete}
  end

  def self.down
  end
end
