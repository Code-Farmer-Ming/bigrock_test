require 'test_helper'

class SpecialitiesControllerTest < ActionController::TestCase
  def setup
    @resume_one=resumes(:one)
    @user_one = users(:one)
    login_as(@user_one)
  end
 

  test "should get new" do
    get :new,:resume_id=>@resume_one.id
    assert_response :success
  end

  test "should create speciality" do
    assert_difference('Speciality.count') do
      post :create, :speciality => {:name=>"vc++" },:resume_id=>@resume_one.id,:user_id=>@user_one.id
    end
#    assert_redirected_to user_resume_speciality_path(@user_one.id,@resume_one.id,assigns(:speciality))
  end

 
  test "should get edit" do
    get :edit, :id => specialities(:one).to_param,:resume_id=>@resume_one.id,:user_id=>@user_one.id
    assert_response :success
  end

  test "should update speciality" do
    put :update, :id => specialities(:one).to_param, :speciality => {:name=>"c#" },:resume_id=>@resume_one.id,:user_id=>@user_one.id
    #assert_redirected_to  user_resume_speciality_path(@user_one.id,@resume_one.id,assigns(:speciality))
  end

  test "should destroy speciality" do
    assert_difference('Speciality.count', -1) do
      delete :destroy, :id => specialities(:one).to_param,:resume_id=>@resume_one.id,:user_id=>@user_one.id
    end
    assert_redirected_to user_resume_specialities_path(@user_one,@resume_one)
  end
end
