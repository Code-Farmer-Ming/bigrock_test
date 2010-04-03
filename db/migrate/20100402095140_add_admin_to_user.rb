class AddAdminToUser < ActiveRecord::Migration
  def self.up
    change_column(:users,:id, :integer)
    execute "INSERT INTO #{quote_table_name(:users)} "+
      "SET `id`=-1,`email`='admin@shuikaopu.system',`password`='cc991fe752b9e10f44a6a9e2a9847529376616b9xxx',
      `is_active`=0,`parent_id`=-1,`created_at`='2010-03-04 12:14:40',
      `updated_at`='2010-03-04 12:14:40',
      `nick_name`='系统',`state`='working',`salt`='cc991fe752b9e10f44a6a9e2a9847529376616b9x';"
    execute "ALTER TABLE  #{quote_table_name(:users)} CHANGE COLUMN `id` `id` int(11) NOT NULL,
            DROP PRIMARY KEY;"
    change_column(:users,:id,:primary_key )
  end

  def self.down
   if User.find_by_id(-1)
     User.find(-1).destroy
   end
  end
end
