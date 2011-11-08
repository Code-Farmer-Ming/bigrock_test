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

  test "following" do
    get :following ,:id=>@user_one
    assert_response :success
  end
  
  test "show" do
    get :show ,:id=>@user_one
    assert_response :success
  end

  test "colleague list" do
    get :colleague_list ,:id=>users(:one).id
    assert_response :success
    get :colleague_list ,:id=>users(:one).id,:pass_id=>users(:one).passes.first
    assert_response :success
  end
 
end
