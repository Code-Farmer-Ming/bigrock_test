class CreateGroupTypes < ActiveRecord::Migration
  def self.up
    create_table :group_types do |t|
      t.string :name,:limit=>16

      t.timestamps
    end
        #公司类型
    types=["情感","学习","IT","娱乐"]

    types.each do |type|
      GroupType.create(:name=>type)
    end
  end

  def self.down
    drop_table :group_types
  end
end
