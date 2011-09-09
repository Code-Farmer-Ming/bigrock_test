class DeleteInvalidDataLogItem < ActiveRecord::Migration
  def self.up
    LogItem.destroy_all(:log_type=>"register_account")
    LogItem.find_all_by_log_type("Attention").each { |item|
      if  item.owner ==item.logable
        item.destroy
      end
    }
  end

  def self.down
  end
end
