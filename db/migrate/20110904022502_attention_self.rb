class AttentionSelf < ActiveRecord::Migration
  def self.up
    User.real_users.each { |e|
      e.add_attention(e)
    }
  end

  def self.down
    User.real_users.each { |e|
      e.remove_attention(e)
    }
  end
end
