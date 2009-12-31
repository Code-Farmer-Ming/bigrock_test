class CreateMsgResponses < ActiveRecord::Migration
  def self.up
    create_table :msg_responses do |t|
      t.integer :msg_id
      t.integer :sender_id
      t.string :content
      t.boolean :is_check,:default=>false

      t.timestamps
    end
  end

  def self.down
    drop_table :msg_responses
  end
end
