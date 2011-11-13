require 'test_helper'

class FriendsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    @user_one = users(:one)
    @user_one.add_friend(users(:three))
    login_as(@user_one)
  end
  
  test "index" do
    get :index,:user_id=>1
    assert_response :success
  end
  
  test "cancel" do
    assert_difference "@user_one.friends.count" ,-1 do
      delete :cancel,:user_id=>users(:three).id
    end
  end
  
  test "cancel xhr" do
    assert_difference "@user_one.friends.count" ,-1 do
      xhr :delete,:cancel,:user_id=>users(:three).id
    end
    
  end
end
