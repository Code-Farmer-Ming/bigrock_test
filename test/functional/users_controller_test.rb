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

  test "friend" do
    get :friends ,:id=>@user_one
    assert_response :success
  end
  
  test "friend my_follow" do
    get :friends ,:id=>@user_one,:type=>:my_follow
    assert_response :success
  end
  
  test "friend follow_me" do
    get :friends ,:id=>@user_one,:type=>:follow_me
    assert_response :success
  end
  
  test "friend follow_company" do
    get :friends ,:id=>@user_one,:type=>:follow_company
    assert_response :success
  end
 
end
