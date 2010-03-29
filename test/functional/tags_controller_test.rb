require 'test_helper'

class TagsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
    def setup
    @user_one = users(:one)
    login_as(@user_one)
  end
  test "index" do
    #默认 查询 Company所有的Tag
    get :index
    assert_equal 2,assigns(:tags).size
    assert_equal "公司",assigns(:label)
    get :index,:search=>tags(:tags_001).name
    assert_equal tags(:tags_001).name,assigns(:tags).first.name
    
  end
  test "index group" do
    #默认 查询 Company所有的Tag
    get :index,:type=>"Group"
    assert_equal 2,assigns(:tags).size
    assert_equal "小组",assigns(:label).to_s
    get :index,:search=>tags(:tags_001).name
    assert_equal tags(:tags_001).name,assigns(:tags).first.name
  end
  
  test "index company 1" do
    get :index,:company_id=>1
    assert_response :success
    assert_equal tags(:tags_001).name,assigns(:owner).tag_list
  end
  
  test "index group 1" do
    get :index,:group_id=>1
    assert_response :success
    assert_equal tags(:tags_002).name,assigns(:owner).tag_list
  end
  
  test "show" do
    get :show,:id=>1
    assert_response :success
  end
  
  test "show company" do
    get :show,:id=>1,:type=>"Company"
    assert_response :success
    assert_equal 2,assigns(:objects).size
    assert_equal companies(:one),assigns(:objects).first
  end

  test "show group" do
    get :show,:id=>1,:type=>"Group"
    assert_response :success
    assert_equal 1,assigns(:objects).size
    assert_equal groups(:two),assigns(:objects).first
  end
end
