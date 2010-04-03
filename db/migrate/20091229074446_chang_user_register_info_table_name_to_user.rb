class ChangUserRegisterInfoTableNameToUser < ActiveRecord::Migration
  def self.up
    rename_table("user_register_infos", "users")
    Attention.all(:conditions=>["target_type=?","UserRegisterInfo"]).each { |item| item.update_attribute("target_type", "User")  }
    Requisition.all(:conditions=>["applicant_type=?","UserRegisterInfo"]).each { |item| item.update_attribute("applicant_type", "User")  }
    LogItem.all(:conditions=>["logable_type=?","UserRegisterInfo"]).each { |item| item.update_attribute("logable_type", "User")  }
    LogItem.all(:conditions=>["owner_type=?","UserRegisterInfo"]).each { |item| item.update_attribute("owner_type", "User")  }
    User.create(:nick_name=>"系统管理员",
      :email=>"system@system.com",
      :text_password=>"system",
      :parent_id =>-1,
      :is_active=>false)
  end

  def self.down
    rename_table("users", "user_register_infos")
  end
end