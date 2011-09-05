class AttentionGroup < ActiveRecord::Migration
  def self.up
    User.all.each() do |user|
      user.all_groups.each() do |group|
        user.add_attention(group)
      end
    end

  end

  def self.down
    User.all.each() do |user|
      user.all_groups.each() do |group|
        user.remove_attention(group)
      end
    end
  end
end
