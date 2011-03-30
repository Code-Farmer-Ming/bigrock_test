require 'test_helper'

class NeedJobsControllerTest < ActionController::TestCase
  def setup
    login_as(users(:one))
  end
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:need_jobs)
  end

  test "should get new" do
  
    get :new
    assert_response :success
  end

  test "should create need_job" do
    assert_difference('NeedJob.count') do
      post :create, :need_job => { }
    end

    assert_redirected_to need_job_path(assigns(:need_job))
  end

  test "should show need_job" do
    get :show, :id => need_jobs(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => need_jobs(:one).to_param
    assert_response :success
  end

  test "should update need_job" do
    put :update, :id => need_jobs(:one).to_param, :need_job => { }
    assert_redirected_to  need_job_path(assigns(:need_job))
  end

  test "should destroy need_job" do
    assert_difference('NeedJob.count', -1) do
      delete :destroy, :id => need_jobs(:one).to_param
    end
    assert_redirected_to account_need_jobs_path
  end

  test "should batch destroy" do
    assert_difference("NeedJob.count",-2) do
      delete :batch_destroy,:select_ids=>[ need_jobs(:one).to_param, need_jobs(:two).to_param]
    end
  end

  test "should batch destroy" do
    delete :batch_destroy
    assert_response :success
  end
end
