require 'test_helper'

class UsersControllerTest < ActionController::TestCase
 
  def setup
    @user_one = users(:one)
    login_as(@user_one)
  end
  
  test "groups" do
    get :groups,:id=>@user_one
    assert_response :success
  end



end
