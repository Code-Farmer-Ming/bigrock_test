require 'test_helper'

class MembersControllerTest < ActionController::TestCase
  def setup
    login_as(users(:two))
  end
  test "index" do
    get :index ,:group_id=>1
    assert_response :success
  end
  
  test "manager to normal" do
    assert_difference("groups(:one).managers.count",-1) do
      xhr :post,:to_normal ,:group_id=>groups(:one).id,:id=>users(:user_005).id
    end
  end
  
  test "to normal already normal" do
    assert_difference("groups(:one).normal_members.count",0) do
      xhr :post,:to_normal ,:group_id=>groups(:one).id,:id=>users(:one).id
    end
  end

  test "to normal not in group" do
    assert_difference("groups(:one).normal_members.count",0) do
      xhr :post,:to_normal ,:group_id=>groups(:one).id,:id=>users(:user_016).id
    end
  end

  test "normal to manager" do
    assert_difference("groups(:one).managers.count") do
      xhr :post,:to_manager ,:group_id=>groups(:one).id,:id=>users(:one).id
    end
  end

  test "to manager user not in group error" do
    assert_difference("groups(:one).managers.count",0) do
      xhr :post,:to_manager ,:group_id=>groups(:one).id,:id=>users(:user_016).id
    end
    assert_not_nil flash[:error]
  end

  test "to manager current user not root error" do
    login_as(users(:one))
    assert_difference("groups(:one).managers.count",0) do
      xhr :post,:to_manager ,:group_id=>groups(:one).id,:id=>users(:user_014).id
    end
    assert_not_nil flash[:error]
  end

  test "to manager user already in group error" do
    groups(:one).managers.clear
    assert_difference("groups(:one).managers.count",1) do
      xhr :post,:to_manager ,:group_id=>groups(:one).id,:id=>users(:user_014).id
    end
    assert_difference("groups(:one).managers.count",0) do
      xhr :post,:to_manager ,:group_id=>groups(:one).id,:id=>users(:user_014).id
    end
  end
  
  test "to manager 10 manager" do
    assert_difference("groups(:one).managers.count") do
      xhr :post,:to_manager ,:group_id=>groups(:one).id,:id=>users(:user_015).id
    end
    assert_difference("groups(:one).managers.count",0) do
      xhr :post,:to_manager ,:group_id=>groups(:one).id,:id=>users(:one).id
    end
    assert_equal "小组最多只能有10个管理员。",flash[:notice]
  end
  test "just one root to manager" do
    assert_difference("groups(:one).managers.count",0) do
      xhr :post,:to_manager ,:group_id=>groups(:one).id,:id=>users(:two).id
    end
    assert_equal "现在不能退出小组,小组必须有一个组长，在指定其他人为组长后才能退出。",flash[:notice]
  end

  test "just one root to normal" do
    assert_difference("groups(:one).normal_members.count",0) do
      xhr :post,:to_normal ,:group_id=>groups(:one).id,:id=>users(:two).id
    end
    assert_equal "现在不能退出小组,小组必须有一个组长，在指定其他人为组长后才能退出。",flash[:notice]
  end
  
  test "to root" do
    assert_difference("groups(:one).roots.count") do
      xhr :post,:to_root ,:group_id=>groups(:one).id,:id=>users(:one).id
    end
  end
  
  test "to root user not in group" do
    assert_difference("groups(:one).roots.count",0) do
      xhr :post,:to_root ,:group_id=>groups(:one).id,:id=>users(:user_016).id
    end
  end

  test "to root root count >2" do
    assert_difference("groups(:one).roots.count",1) do
      xhr :post,:to_root ,:group_id=>groups(:one).id,:id=>users(:user_014).id
      xhr :post,:to_root ,:group_id=>groups(:one).id,:id=>users(:user_015).id
    end
    assert_equal "小组最多只能有2个组长。",flash[:notice]
  end
  test "root to manager" do
    assert_difference("groups(:one).roots.count") do
      xhr :post,:to_root ,:group_id=>groups(:one).id,:id=>users(:one).id
    end
    assert_difference("groups(:one).managers.count") do
      xhr :post,:to_manager ,:group_id=>groups(:one).id,:id=>users(:one).id
    end
  end
  
  test "root to normal" do
    assert_difference("groups(:one).roots.count") do
      xhr :post,:to_root ,:group_id=>groups(:one).id,:id=>users(:one).id
    end
    assert_difference("groups(:one).normal_members.count") do
      xhr :post,:to_normal ,:group_id=>groups(:one).id,:id=>users(:one).id
    end
  end
  
  test "destroy normal" do
    assert_difference("groups(:one).all_members.count",-1) do
      xhr :delete,:destroy ,:group_id=>groups(:one).id,:id=>users(:one).id
    end
  end
  test "destroy by non manager" do
    login_as(users(:one))
    assert_difference("groups(:one).all_members.count",0) do
      xhr :delete,:destroy ,:group_id=>groups(:one).id,:id=>users(:two).id
    end
  end
  
  test "destroy user not in group" do
    login_as(users(:one))
    assert_difference("groups(:one).all_members.count",0) do
      xhr :delete,:destroy ,:group_id=>groups(:one).id,:id=>users(:three).id
    end
  end

  test "destroy manager" do
    assert_difference("groups(:one).all_members.count",-1) do
      xhr :delete,:destroy ,:group_id=>groups(:one).id,:id=>users(:user_014).id
    end
  end
  
  test "destroy only one root" do
    assert_difference("groups(:one).all_members.count",0) do
      xhr :delete,:destroy ,:group_id=>groups(:one).id,:id=>users(:two).id
    end
    assert_equal "现在不能退出小组,小组必须有一个组长，在指定其他人为组长后才能退出。",flash[:notice]
  end
  
  test "destroy root" do
    xhr :post,:to_root ,:group_id=>groups(:one).id,:id=>users(:user_014).id
    assert_difference("groups(:one).roots.count",-1) do
      xhr :delete,:destroy ,:group_id=>groups(:one).id,:id=>users(:user_014).id
    end
  end
  
end
