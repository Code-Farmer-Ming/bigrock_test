require 'test_helper'

class EducationsControllerTest < ActionController::TestCase
  def setup
    @resume=resumes(:one)
    @user=users(:one)
    login_as(@user)
  end


  test "should get new" do
    get :new,:user_id=>@user.id 
    assert_response :success
  end

  test "should create education" do

    assert_difference('Education.count') do
      post :create, :education => {:school_name=>"sjtu",:begin_date=>"2007-02-03",:end_date=>"2009-02-04"},:user_id=>@user.id
    end
    #assert_redirected_to new_user_resume_education_path(@user.id,@resume.id)
  end
 

  test "should get edit" do
    get :edit, :id => educations(:one).to_param,:user_id=>@user.id
    assert_response :success
  end

  test "should update education" do
    put :update, :id => educations(:one).to_param, :education => { },:user_id=>@user.id
    #    assert_redirected_to user_resume_education_path(@user.id,@resume.id,assigns(:education))
  end

  test "should destroy education" do
    assert_difference('Education.count', -1) do
      delete :destroy, :id => educations(:one).to_param,:user_id=>@user.id
    end
    #assert_redirected_to user_resume_educations_path(@user.id,@resume.id)
  end
end
