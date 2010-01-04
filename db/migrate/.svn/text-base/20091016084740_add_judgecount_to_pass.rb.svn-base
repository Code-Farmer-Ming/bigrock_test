class AddJudgecountToPass < ActiveRecord::Migration
  def self.up
    add_column :passes, :judges_count, :integer , :default=>0
  end

  def self.down

    remove_column :passes, :judges_count
  end
end
