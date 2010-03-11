require 'test_helper'

class PassesControllerTest < ActionController::TestCase
  def setup
    @userone=users(:one)
    @resumeone=resumes(:one)
    login_as(@userone)
  end


  test "should get new" do

    xhr :get, :new,:user_id=>@userone,:resume_id=>@resumeone
    assert_response :success
  end

  test "should create pass" do
    assert_difference('Pass.count') do
      post :create, :pass => {:title=>"普通员工" },:user_id=>@userone,:resume_id=>@resumeone,:company=>{:name=>"MyString"}
    end
    assert_redirected_to @userone
    resume= Pass.find_all_by_resume_id(@resumeone)
    assert(resume.length>0,"count error"+resume.length.to_s)
    assert_equal(resume[0].resume_id,@resumeone.id)  
  end


  test "should get edit" do
    get :edit, :id => passes(:one).to_param,:user_id=>@userone,:resume_id=>@resumeone
    assert_response :success
  end

  test "should update pass" do
    put :update, :id => passes(:one).to_param ,:user_id=>@userone,:resume_id=>@resumeone,:pass => {:title=>"MyString11" },:company=>{:name=>"MyString"}
    # assert_redirected_to user_resume_pass_path(@userone,@resumeone,assigns(:pass))
    pass= Pass.find(:first)
    assert_equal(pass.title,"MyString11")
  end

  test "should destroy pass" do
    assert_difference('Pass.count', -1) do
      delete :destroy, :id => passes(:one).to_param,:user_id=>@userone,:resume_id=>@resumeone
    end
    #assert_redirected_to user_resume_passes_path(@userone,@resumeone)
  end
end
