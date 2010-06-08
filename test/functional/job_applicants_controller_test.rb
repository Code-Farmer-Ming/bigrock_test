require 'test_helper'

class JobApplicantsControllerTest < ActionController::TestCase
  def setup
    login_as(users(:one))
  end
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:job_applicants)
  end

  test "should get new" do
    xhr :get, :new,:job_id=>jobs(:one),:company_id=>companies(:one)
    assert_response :success
  end

  test "should get recommend talent" do
    xhr :get, :recommend_talent,:job_id=>jobs(:one),:company_id=>companies(:one)
    assert_response :success
  end

  test "should create job_applicant" do
    assert_difference('JobApplicant.count') do
      xhr :post, :create, :job_applicant => {:applicant_id=>users(:two) },:job_id=>jobs(:one),:company_id=>companies(:one)
    end
  end
  
  test "should create job_applicant multi-applicant" do
    assert_difference('JobApplicant.count',2) do
      xhr :post, :create, :job_applicant => {:applicant_user_ids=>'1 2' },:job_id=>jobs(:one),:company_id=>companies(:one)
    end
  end
  test "should create job_applicant blank multi-applicant" do
    assert_difference('JobApplicant.count',0) do
      xhr :post, :create, :job_applicant => {:applicant_user_ids=>'' },:job_id=>jobs(:one),:company_id=>companies(:one)
    end
  end
  test "should show job_applicant" do
    get :show, :id => job_applicants(:one).to_param,
      :job_id=>jobs(:one),:company_id=>companies(:one)
    assert_response :success
  end

  

  test "should destroy job_applicant" do
    assert_difference('JobApplicant.count', -1) do
      delete :destroy, :id => job_applicants(:one).to_param
    end

    assert_redirected_to job_applicants_path
  end
end
