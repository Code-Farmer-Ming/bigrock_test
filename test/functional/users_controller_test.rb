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
  
  test "my follow user" do
    get :following ,:id=>@user_one,:type=>:user
    assert_response :success
  end
#
#  test "friend follow_me" do
#    get :following ,:id=>@user_one,:type=>:follow_me
#    assert_response :success
#  end
  
  test " follow_company" do
    get :following ,:id=>@user_one,:type=>:company
    assert_response :success
  end
 
end
