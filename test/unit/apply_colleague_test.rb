require 'test_helper'

class ApplyColleagueTest < ActiveSupport::TestCase
  
  test "accept" do
    user_one = users(:one)
    user_one.friends.clear
    user_one.targets.clear
    users(:two).friends.clear
    user_one.add_friend(users(:two))
    
    apply = ApplyColleague.new(:respondent_id=>users(:two).id);
    user_one.apply_colleague(apply)
    
    assert_difference("user_one.apply_colleagues.count",-1) do
      assert_difference("user_one.friends.count",-1) do
        assert_difference("user_one.unread_msgs.count") do
          assert_difference("user_one.colleagues.count") do
            apply.accept()
          end
        end
      end
    end


  end
  
end
