#改变education 和 speciality 的所属对象 从 resume 改为 user
class ChangeEducationAndSpecialityOwner < ActiveRecord::Migration
  def self.up
    add_column :educations ,:user_id,:integer
    add_column :specialities ,:user_id,:integer

    Education.all.each do |item|
      item.user = item.resume.user
      item.save
    end

    Speciality.all.each do |item|
      item.user = item.resume.user
      item.save
    end
    remove_column :educations, :resume_id
    remove_column :specialities, :resume_id
    
    remove_index  :specialities,[:resume_id,:skill_id]
    add_index  :specialities,[:user_id,:skill_id]
    
    remove_index  :educations,[:resume_id,:school_id]
    add_index  :educations,[:user_id,:school_id]
  end

  def self.down
    add_column :educations ,:user_id,:resume_id
    add_column :specialities ,:user_id,:resume_id
    remove_column :educations, :user_id
    remove_column :specialities, :user_id
    add_index  :specialities,[:resume_id,:skill_id]
    remove_index  :specialities,[:user_id,:skill_id]
    
    add_index  :educations,[:resume_id,:school_id]
    remove_index  :educations,[:user_id,:school_id]
  end
end
