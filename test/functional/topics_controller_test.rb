require 'test_helper'

class TopicsControllerTest < ActionController::TestCase
  def setup
    @userone=users(:one)
    login_as(@userone)
  end
  
  test "should get index" do
    get :index,{:company_id=>1}
    assert_response :success
    assert_not_nil assigns(:topics)
  end

  test "should get company new" do
    get :new,{:company_id=>1}
    assert_response :success
    assert_not_nil assigns(:topic)
  end

  test "should get group new" do
    get :new,{:group_id=>1}
    assert_response :success
    assert_not_nil assigns(:topic)
  end
  
  test "should get group new with not enough authorization" do
    login_as(users(:user_017))
    get :new,{:group_id=>1}
    assert_response 302
    assert_equal "你无权限发表内容！", flash[:notice]
  end

  test "should create company topic" do
    assert_difference('Topic.count') do
      post :create, :topic => {:author_id=>1,:title=>"",:content=>""},:company_id=>1
    end
    assert_redirected_to [assigns(:topic).owner,assigns(:topic)]
  end
  
  test "should create company topic with alias" do
    assert_difference('Topic.count') do
      post :create, :topic => {:title=>"with alias" },:company_id=>1,:alias=>@userone.aliases.first.to_param
    end
    assert_redirected_to [assigns(:topic).owner,assigns(:topic)]
    assert_equal @userone.aliases.first,assigns(:topic).author
  end
  
  test "should create group topic" do
    assert_difference('Topic.count') do
      post :create, :topic => {:title=>"test" },:group_id=>1
    end
    assert_redirected_to [assigns(:topic).owner,assigns(:topic)]
    assert_equal @userone,assigns(:topic).author
  end
  

  test "should show topic" do
    get :show, :id => topics(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => topics(:one).to_param
    assert_response :success
  end

  test "should update topic" do
    put :update, :id => topics(:one).to_param, :topic => { }
    assert_redirected_to [assigns(:topic).owner,assigns(:topic)]
  end

  test "should destroy topic" do
    assert_difference('Topic.count', -1) do
      delete :destroy, :id => topics(:one).to_param
    end
    assert_redirected_to  topics(:one).owner
  end
  
  test "not authorization destroy topic" do
    login_as(users(:three))
    assert_difference('Topic.count', 0) do
      delete :destroy, :id => topics(:one).to_param
    end
    assert_equal "删除错误", flash[:error]
  end
  
  test "up" do
    xhr :post ,:up,:company_id=>topics(:one).owner.id,:id=>topics(:one)
    topics(:one).reload
    assert_equal 1,topics(:one).up
  end
  test "down" do
    xhr :post ,:down,:company_id=>topics(:one).owner.id,:id=>topics(:one)
    topics(:one).reload
    assert_equal 1,topics(:one).down
  end
  # 设置 置顶
  #正确权限
  test "set top level with enough authorization" do
    xhr :post ,:set_top_level,:company_id=>topics(:one).owner.id,:id=>topics(:one)
    topics(:one).reload
    assert_equal true,topics(:one).top_level
    assert_equal "置顶成功！" ,flash[:success]
  end
  #不正确权限
  test "set top level with not enough authorization" do
    login_as(users(:three))
    xhr :post ,:set_top_level,:company_id=>topics(:one).owner.id,:id=>topics(:one)
    topics(:one).reload
    assert_equal false,topics(:one).top_level
    assert_equal "设置错误" ,flash[:error]
  end


  #取消置顶
  test "cancel top level with enough authorization" do
    topics(:one).top_level = true
    topics(:one).save
    xhr :post ,:cancel_top_level,:company_id=>topics(:one).owner.id,:id=>topics(:one)
    topics(:one).reload
    assert_equal false,topics(:one).top_level
    assert_equal "取消成功！" ,flash[:success]
  end
  test "cancel top level with not enough authorization" do
    topics(:one).top_level = true
    topics(:one).save
    login_as(users(:three))
    xhr :post ,:cancel_top_level,:company_id=>topics(:one).owner.id,:id=>topics(:one)
    topics(:one).reload
    assert_equal true,topics(:one).top_level
    assert_equal "设置错误" ,flash[:error]
  end
end
