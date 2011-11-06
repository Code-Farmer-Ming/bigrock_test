require 'test_helper'

class FriendsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  
  test "index" do
    get :index,:user_id=>1
    assert_response :success
  end
end
