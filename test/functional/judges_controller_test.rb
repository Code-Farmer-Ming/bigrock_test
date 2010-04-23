require 'test_helper'

class JudgesControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    login_as(users(:one))
  end
  test "create" do
    user_2 = users(:two)
    assert_block("user_2.judges.count") do
      xhr :post,:create,:judge=>{:anonymous=>1,:description=>"不错的小伙",
        :creditability_value=>1,:eq_value=>1,:ability_value=>1},
        :my_tags=>"辖门",
        :user_id=>user_2.id,
        :pass_id=>user_2.passes.first
    end
    get  :index ,:user_id=>user_2.id
    assert_response :success
  end
end
