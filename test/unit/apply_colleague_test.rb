require 'test_helper'

class ApplyColleagueTest < ActiveSupport::TestCase
  
  test "accept" do
    user_one = users(:one)
    apply = ApplyColleague.new(:respondent_id=>users(:two).id);
    user_one.apply_colleague(apply)
    assert_difference("user_one.unread_msgs.count") do
      assert_difference("user_one.colleagues.count") do
        apply.accept()
      end
    end


  end
  
end
