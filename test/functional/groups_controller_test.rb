require 'test_helper'

class GroupsControllerTest < ActionController::TestCase
  def setup
    login_as(users(:one))
  end
  test "should get index" do
    get :index
    assert_response :success
#    assert_not_nil assigns(:groups)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "get new when manage group count>4" do
    users(:one).groups.clear
    for i in 1..4
      post :create, :group => {:name=>"test group#{i}", :group_type_id=>0,:join_type=> Group::JOIN_TYPES[0][1]}
    end
    get :new
    assert_redirected_to groups_path
  end
  
  test "should create group" do
    assert_difference('Group.count') do
      post :create, :group => {:name=>"test group", :group_type_id=>0,:join_type=> Group::JOIN_TYPES[0][1],:tag_list=>"test"}
    end
    assert_redirected_to group_path(assigns(:group))
    assert_equal Group::JOIN_TYPES[0][1],Group.find_by_name("test group").join_type
    assert_equal users(:one), Group.find_by_name("test group").create_user
  end
  test "create group with same name" do
    assert_difference('Group.count') do
      post :create, :group => {:name=>"test group", :group_type_id=>0,:join_type=> Group::JOIN_TYPES[0][1]}
    end
    assert_difference('Group.count',0) do
      post :create, :group => {:name=>"test group", :group_type_id=>0,:join_type=> Group::JOIN_TYPES[0][1]}
    end
     

  end
  
  test "should create group with alias" do
    assert_difference('Group.count') do
      post :create, :group => {:name=>"test group", :group_type_id=>0,:join_type=> Group::JOIN_TYPES[0][1]},
        :alias=>users(:one).alias.to_param
    end
    assert_redirected_to group_path(assigns(:group))
    assert_equal Group::JOIN_TYPES[0][1],Group.find_by_name("test group").join_type
    assert_equal users(:one).alias, Group.find_by_name("test group").create_user
  end
  #创建 需要申请加入的小组
  test "should create application group" do
    Group.destroy_all()
    assert_difference('Group.count') do
      post :create, :group => {:name=>"test group", :group_type_id=>0,:join_type=>Group::JOIN_TYPES[1][1]}
    end
    assert_equal Group::JOIN_TYPES[1][1],Group.find_by_name("test group").join_type
  end

  #创建 秘密小组
#  test "should create secret group" do
#    Group.destroy_all()
#    assert_difference('Group.count') do
#      post :create, :group => {:name=>"test group", :group_type_id=>0,:join_type=>Group::JOIN_TYPES[2][1] }
#    end
#    assert_equal Group::JOIN_TYPES[2][1],Group.find_by_name("test group").join_type
#  end

  test "should show group" do
    get :show, :id => groups(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    login_as(users(:two))
    get :edit, :id => groups(:one).to_param
    assert_response :success
  end

  test "should update group" do
    put :update, :id => groups(:one).to_param, :group => { }
    assert_redirected_to group_path(assigns(:group))
  end

  test "should destroy group" do
    login_as(users(:two))
    assert_difference('Group.count', -1) do
      delete :destroy, :id => groups(:one).to_param
    end
    assert_redirected_to groups_path
  end
  test "join group" do
    login_as(users(:user_016))
    assert_difference('Member.count') do
      xhr :post, :join, :id => groups(:one).to_param
    end
  end
  #开放式权限 加入小组 已经加入
  test "join group already joined" do
    assert_difference('Member.count',0) do
      xhr :post, :join, :id => groups(:one).to_param
    end
  end
  #开放式权限 加入小组
  test "join group error" do
    xhr :post, :join, :id => groups(:two).to_param
    assert_equal "加入小组出错!",flash.now[:error]
  end

  test "quit" do
    login_as(users(:three))
    Member.delete_all
    assert_equal 0,groups(:one).members_count
    assert_difference('Member.count') do
      xhr :post, :join, :id => groups(:one).to_param
    end
    groups(:one).reload()
    assert_equal 1,groups(:one).members_count
    
    assert_difference('Member.count',-1) do
      xhr :post, :quit, :id => groups(:one).to_param
    end
    groups(:one).reload()
    assert_equal 0,groups(:one).members_count
 
  end
  
  test "join invite  get" do
    get :invite_join,:id=>groups(:one).id
    assert_response :success
  end
  
  test "join invite  post" do
    JoinGroupInvite.destroy_all
    assert_difference("JoinGroupInvite.count",2) do
      post  :invite_join,:id=>groups(:one).id,:invite_user=>[16,3],:join_group_invite=>{:memo=>"ok"}
    end
  end
  
  test "search" do
    
  end
  
end
