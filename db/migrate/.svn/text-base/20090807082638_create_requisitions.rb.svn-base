class CreateRequisitions < ActiveRecord::Migration
  #TODO: 表结构需要考虑 扩充性
  def self.up
    create_table :requisitions do |t|
      t.integer :applicant_id
      t.integer :respondent_id
      t.string :type
      t.string :memo

      t.timestamps
    end
  end

  def self.down
    drop_table :requisitions
  end
end
