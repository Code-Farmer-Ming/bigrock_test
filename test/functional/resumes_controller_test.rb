require 'test_helper'

class ResumesControllerTest < ActionController::TestCase
  def setup
    login_as   users(:one)
  end
 

#  test "should get new" do
#    user=users(:one)
#    get :new,:user_id=>user
#    assert_response :success
#  end

#  test "should create resume" do
#    user=users(:one)
#    assert_difference('Resume.count') do
#      post :create,:resume => {:name=>"name"},:user_id=>user
#    end
#
#    assert_redirected_to user_resumes_path()
#
#  end

#  test "should show resume" do
#    user=users(:one)
#    get :show, :id => resumes(:one).to_param,:user_id=>user.to_param
#    assert_response :success
#  end

#  test "should get edit" do
#    user=users(:one)
#    xhr :get, :edit, :id => resumes(:one).to_param,:user_id=>user
#
#  end

  test "should update resume" do
    user=users(:one)
    put :update, :id => resumes(:one).to_param, :resume => {:name=>"qq" },:user_id=>user
    assert_redirected_to user_resumes_path()
  end

#  test "should destroy resume" do
#    user=users(:one)
#    assert_difference('Resume.count', -1) do
#      delete :destroy, :id => resumes(:one).to_param,:user_id=>user
#    end
#
#    assert_redirected_to user_resumes_path
#  end
end
