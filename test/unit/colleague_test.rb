require 'test_helper'

class ColleagueTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "add judge" do
    user_1 = users(:one)
    user_2 = users(:two)
    user_1.add_colleague(user_2)
     assert true
  end
end
