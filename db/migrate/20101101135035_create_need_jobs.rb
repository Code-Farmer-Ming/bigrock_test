class CreateNeedJobs < ActiveRecord::Migration
  def self.up
    create_table :need_jobs do |t|
      t.string :title
      t.string :description
      t.integer :state_id
      t.integer :city_id
      t.integer :poster_id

      t.timestamps
    end
  end

  def self.down
    drop_table :need_jobs
  end
end
