require 'test_helper'

class PassesControllerTest < ActionController::TestCase
  def setup
    @userone=users(:one)
    login_as(@userone)
  end


  test "should get new" do

    xhr :get, :new,:user_id=>@userone,:resume_id=>@resumeone
    assert_response :success
  end

  test "should create pass" do
    Pass.destroy_all()
    assert_difference('@userone.passes.count') do
      post :create, :pass => {:title=>"普通员工" ,:begin_date=> "2009-06-01",:end_date=> "2009-06-01"},:user_id=>@userone, :company=>{:name=>"MyString"}
    end
    assert_redirected_to @userone
  end

  test "should create pass with request user id nil" do
    Pass.destroy_all()
    post :create, :pass => {:title=>"普通员工",:begin_date=> "2009-06-01",:end_date=> "2009-06-01" },
      :user_id=>@userone,:resume_id=>@resumeone,:company=>{:name=>"MyString"},:request_user_id=>nil
    assert_redirected_to user_path(1)
  end

  test "should create pass with request user id blank " do
    Pass.destroy_all()
    post :create, :pass => {:title=>"普通员工" ,:begin_date=> "2009-06-01",:end_date=> "2009-06-01"},
      :user_id=>@userone,:resume_id=>@resumeone,:company=>{:name=>"MyString"},:request_user_id=>""
    assert_redirected_to user_path(1)
  end

  test "should get edit" do
    get :edit, :id => passes(:one).to_param,:user_id=>@userone,:resume_id=>@resumeone
    assert_response :success
  end

  test "should update pass" do
    put :update, :id => passes(:one).to_param ,:user_id=>@userone,:resume_id=>@resumeone,:pass => {:title=>"MyString11"},:company=>{:name=>"MyString"}
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

  test "send invite with validate email" do
    xhr :post ,:send_invite ,:id=>passes(:two),:msg=>{:sendees=>"xiao@gmail.com;xx",:title=>"",:content=>"test"}
    assert_equal flash[:error],'xx 无效的邮箱地址！'
    #      assert_equal 2, ActionMailer::Base.deliveries.size
  end
  test "send invite with validate yokemate" do
    xhr :post ,:send_invite ,:id=>passes(:two),:msg=>{:sendees=>"xiao@gmail.com;xx@gmail.com",:title=>"",:content=>"test"},:colleagues=>[22,33,44]
    assert_not_nil flash[:error]
  end
end
