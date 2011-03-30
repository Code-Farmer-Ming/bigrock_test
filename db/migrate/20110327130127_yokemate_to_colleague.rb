class YokemateToColleague < ActiveRecord::Migration
  def self.up
    Judge.all.each  do |item|
      
      colleague =  Colleague.new
      colleague.user = item.user
      colleague.colleague_user = item.judger
      colleague.is_judge = true
      colleague.state = Colleague::STATES[1]
      colleague.my_pass = item.pass
      colleague.company = item.pass.company
      colleague.colleague_pass = item.judger.passes.find_by_company_id(item.pass.company.id)
      colleague.judge = item
      colleague.save


    end
    Colleague.all.each  do |colleague|
      if Colleague.
          find_all_by_user_id_and_colleague_id_and_my_pass_id(colleague.colleague_user.id,
          colleague.user.id,colleague.colleague_pass.id).size==0
        colleague2 =  Colleague.new
        colleague2.user = colleague.colleague_user
        colleague2.colleague_user =  colleague.user
        colleague2.state = Colleague::STATES[1]
        colleague2.my_pass = colleague.colleague_pass
        colleague2.company = colleague.company
        colleague2.colleague_pass = colleague.my_pass
        colleague2.save
      end
    end
  end

  def self.down
  end
end
