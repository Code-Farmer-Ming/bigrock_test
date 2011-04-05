class UpdateColleague< ActiveRecord::Migration
  def self.up
    User.all.each do |user|
      user.passes.each { |pass|
        add_passes= pass.real_get_same_company_pass - pass.record_passes
        add_passes.each do |add_pass|
          pass.colleagues << Colleague.new(:colleague_pass=>add_pass,:user=>user,:colleague_user=>add_pass.user,:company=>pass.company ,:state=>Colleague::STATES[1])
          add_pass.all_colleagues << Colleague.new(:colleague_pass=>pass,:user=>add_pass.user,:colleague_user=>pass.user,:company=>pass.company,:state=>Colleague::STATES[1])
        end
      }
    end
   LogItem.find_all_by_log_type('friend') do |logitem|
      logitem.delete
    end


  end

  def self.down
    
  end
end
