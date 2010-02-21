require 'test_helper'

class NewsControllerTest < ActionController::TestCase
  def setup
    login_as(users(:one))
  end
  test "should get index" do
    get :index,:company_id=>1
    assert_response :success
    assert_not_nil assigns(:news)
  end

  test "should get new" do
    pass1 = users(:one).passes.find_by_company_id(1)
    pass1.creditability_value = 5
    pass1.judges_count=1
    pass1.save
    get :new,:company_id=>1
    assert_response :success
  end
  
  test "get new without authorization" do
    login_as(users(:user_017))
    get :new,:company_id=>1
    assert_redirected_to company_path(assigns(:company))
  end

  test "should create news" do
    assert_difference('Piecenews.count') do
      post :create, :piecenews => {:title=>"title",:content=>"test" },:company_id=>1
    end
    assert_equal "title",assigns(:piece_of_news).title
    assert_equal "test",assigns(:piece_of_news).content
    assert_redirected_to company_piecenews_path(assigns(:company),assigns(:piece_of_news))
  end

  test "should show news" do
    get :show, :id => news(:one).to_param,:company_id=>1
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => news(:one).to_param,:company_id=>1
    assert_redirected_to company_path(assigns(:company))
    pass1 = users(:one).passes.find_by_company_id(1)
    pass1.creditability_value = 5
    pass1.judges_count=1
    pass1.save
    get :edit, :id => news(:one).to_param,:company_id=>1
    assert_response :success
  end

  test "should update news" do
    put :update, :id => news(:one).to_param, :piecenews => {:title=>"new title" ,:content=>"new content"},:company_id=>1
    assert_redirected_to company_piecenews_path(1,assigns(:piece_of_news))
    assert_equal "new title",assigns(:piece_of_news).title
    assert_equal "new content",assigns(:piece_of_news).content
  end

  test "should destroy news" do
    assert_difference('Piecenews.count', 0) do
      delete :destroy, :id => news(:one).to_param,:company_id=>1
    end
    pass1 = users(:one).passes.find_by_company_id(1)
    pass1.creditability_value = 5
    pass1.judges_count=1
    pass1.save
    assert_difference('Piecenews.count', -1) do
      delete :destroy, :id => news(:one).to_param,:company_id=>1
    end
    assert_redirected_to company_news_path(1)
  end

  test "up_news" do
    get :show, :id => news(:one).to_param,:company_id=>1
    assert_response :success
    xhr :post,:up,:id=>news(:one).to_param
    news(:one).reload
    assert_equal 1,news(:one).up
  end

  test "down_news" do
    get :show, :id => news(:one).to_param,:company_id=>1
    assert_response :success
    xhr :post,:down,:id=>news(:one).to_param
    news(:one).reload
    assert_equal 1,news(:one).down
  end
end
