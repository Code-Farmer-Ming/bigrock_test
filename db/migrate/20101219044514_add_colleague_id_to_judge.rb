class AddColleagueIdToJudge < ActiveRecord::Migration
  def self.up
    add_column :judges, :colleague_id, :integer
  end

  def self.down
    remove_column :judges, :colleague_id
  end
end
