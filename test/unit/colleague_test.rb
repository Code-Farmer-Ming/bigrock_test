require 'test_helper'

class ColleagueTest < ActiveSupport::TestCase

  def setup
    create_colleague
  end
  test "confirm colleague" do
    
    assert_equal Colleague::STATES[0], Colleague.first.state
    assert_difference "Colleague.first.colleague_user.receive_msgs.count" do
      Colleague.first.confirm_colleague
    end
    assert_equal Colleague::STATES[1], Colleague.first.state

  end

  test "to not colleague" do
    assert_equal Colleague::STATES[0], Colleague.first.state
    Colleague.first.not_colleague
    assert_equal Colleague::STATES[2], Colleague.first.state
  end

  def create_colleague
    #  user_id      :integer
    #  colleague_id :integer
    #  created_at   :datetime
    #  updated_at   :datetime
    #  company_id   :integer
    #  pass_id      :integer

    Colleague.create(:user_id=>1,:colleague_id=>2,:my_pass_id=>12,:colleague_pass_id=>1)
  end
end
