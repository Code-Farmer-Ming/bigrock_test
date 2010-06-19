require 'test_helper'

class JobsControllerTest < ActionController::TestCase
  def setup
    login_as(users(:one))
    @company = companies(:one)
  end
  test "should get index " do
    get :index
    assert_response :success
    assert_nil assigns(:company)
    assert_nil assigns(:jobs)
  end
  test "should get index with company" do
    get :index,:company_id=>@company
    assert_response :success
    assert_not_nil assigns(:company)
    assert_not_nil assigns(:jobs)
  end
  test "should get new" do
    pass = users(:one).current_resume.passes.first
    pass.creditability_value = 4
    pass.save
    get :new,:company_id=>@company
    assert_response :success,flash[:error]
  end
  test "should get new faild" do
    get :new,:company_id=>@company
    assert_response 302 ,flash[:error]
  end

  test "should create job" do
    pass = users(:one).current_resume.passes.first
    pass.creditability_value = 4
    pass.save
    assert_difference('Job.count',1) do
      post :create, :job => {:title=>"new job",
        :job_description=>"work_description",
        :skill_description=>"skill_description",:end_at=>Time.now,
        :type_id=>0,:city_id=>1,:state_id=>1 },:company_id=>@company
    end
    assert_redirected_to company_job_path(@company,assigns(:job))
  end

  test "should show job" do
    get :show, :id => jobs(:one).to_param,:company_id=>@company
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => jobs(:one).to_param,:company_id=>@company
    assert_response :success
  end

  test "should update job" do
    put :update, :id => jobs(:one).to_param, :job => {:title=>"changed title" },
      :company_id=>@company
    assert_equal "changed title",assigns(:job).title
    assert_redirected_to company_job_path(@company,assigns(:job))
  end

  test "should destroy job" do
    @env['HTTP_REFERER'] = 'xx'
    assert_difference('Job.count', -1) do
      delete :destroy,{ :id => jobs(:one).to_param,:company_id=>@company}
    end
    assert_redirected_to company_jobs_path(@company)
  end
end
