class AddStateToUserRegisterInfo < ActiveRecord::Migration
  def self.up
    add_column :user_register_infos, :state, :string,:limit=>12,:default=>User::STATE_TYPES.keys[0].to_s()
    remove_column :resumes, :state
  end

  def self.down
    remove_column :user_register_infos, :state
    add_column :resumes, :state, :string
  end
end
