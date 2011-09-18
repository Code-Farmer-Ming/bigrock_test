class ReAttentionGroup < ActiveRecord::Migration
  def self.up
    User.real_users.each() do |user|
      user.all_groups.each() do |group|
        user.add_attention(group)
      end
    end
  end

  def self.down
    LogItem.find_all_by_log_type("Attention").each { |item|
      if  item.logable_type=="Group"
        item.destroy
      end
    }
  end
  Attention.destroy_all(:target_type=>"Group")
end
