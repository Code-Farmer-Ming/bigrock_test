require 'test_helper'

class WorkItemsControllerTest < ActionController::TestCase
  def setup
    @user_one=users(:one)
    @resume_one=resumes(:one)
    @pass_one = passes(:one)
    login_as(@user_one)
  end
 
#
#  test "should get new" do
#    get :new,:user_id=>@user_one.id,:resume_id=>@resume_one.id,:pass_id=>@pass_one.id
#    assert_response :success
#  end

  test "should create work_item" do
    assert_difference('WorkItem.count') do
      post :create, :work_item => {:name=>"first project" },:user_id=>@user_one.id,:resume_id=>@resume_one.id,:pass_id=>@pass_one.id
    end
    assert_redirected_to user_resume_pass_work_item_path(@user_one,@resume_one,@pass_one, assigns(:work_item))
  end
 
  test "should update work_item" do
    put :update, :id => work_items(:one).to_param, :work_item => {:name=>"yyy" },:user_id=>@user_one.id,:resume_id=>@resume_one.id,:pass_id=>@pass_one.id
  #  assert_redirected_to user_resume_pass_work_item_path(@user_one,@resume_one,@pass_one, assigns(:work_item))
  end

  test "should destroy work_item" do
    assert_difference('WorkItem.count', -1) do
      delete :destroy, :id => work_items(:one).to_param,:user_id=>@user_one.id,:resume_id=>@resume_one.id,:pass_id=>@pass_one.id
    end

    assert_redirected_to user_resume_pass_work_items_path(@user_one,@resume_one,@pass_one)
  end
end
