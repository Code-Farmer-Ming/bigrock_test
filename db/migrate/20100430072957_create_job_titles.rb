class CreateJobTitles < ActiveRecord::Migration
  def self.up
    create_table :job_titles do |t|
      t.references :company
      t.string :name,:null=>false

      t.timestamps
    end
    
    add_column :passes, :job_title_id, :integer,:default=>0
    rename_column :passes,:title,:new_title
    Pass.all.each() do |item|
      item.job_title_id = JobTitle.find_or_create_by_name_and_company_id(item.new_title,item.company_id).id
      item.save
    end
    remove_column(:passes, :new_title)
  end

  def self.down
    drop_table :job_titles
  end
end
