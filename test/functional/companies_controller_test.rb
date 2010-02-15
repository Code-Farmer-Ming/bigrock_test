require 'test_helper'

class CompaniesControllerTest < ActionController::TestCase
  def setup
    login_as(users(:one))
  end
  
  test "index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:newly_companies)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create company" do
    companies(:one).name="new string"
    new_company = companies(:one)
    assert_difference('Company.count') do
      post :create, :company =>new_company.attributes
    end
    assert_redirected_to company_path(assigns(:company))
  end

  test "should show company" do
    get :show, :id => companies(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => companies(:one).to_param
    assert_response :success
  end
 
  test "edit with not enough authorization" do
    login_as(users(:user_017))
    get :edit, :id => companies(:one).to_param
    assert_redirected_to :action => "show"
  end

  test "should update company" do
    put :update, :id => companies(:one).to_param, :company => { }
    assert_redirected_to company_path(assigns(:company))
  end

  test "should destroy company" do
    assert_difference('Company.count', -1) do
      delete :destroy, :id => companies(:one).to_param
    end
    assert_redirected_to companies_path
  end
  
  test "company_tags" do
    get :tags, :id => companies(:one).to_param
    assert_response :success   
  end
  
  test "company_show_by_tag" do
    get :show_by_tag, :tag_id => tags(:tags_001)
    assert_response :success
  end
  
  test "company_news" do
    get :news
    assert_response :success
    assert assigns(:news)
  end
  
  test "search" do
    get :search
    assert_response :success
    get :search,:industry_id=>2
    assert_equal(0,  assigns(:companies).size)

    get :search,:state_id=>2,:city_id=>2,:company_type_id=>2,:company_size_id=>2
    assert_equal(1,  assigns(:companies).size)
    
    get :search,:state_id=>1,:city_id=>1,:company_type_id=>1,:company_size_id=>1
    assert_equal(2,  assigns(:companies).size)

    get :search,:industry_id=>1
    assert_equal(3,  assigns(:companies).size)
  end

end
