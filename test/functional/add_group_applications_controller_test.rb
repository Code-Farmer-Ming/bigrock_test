require 'test_helper'

class AddGroupApplicationsControllerTest < ActionController::TestCase
  def setup
    login_as(users(:two))
  end
  
  test "index" do
    get :index,:group_id=>1
    assert_response :success
  end

  test "accept" do
    g3= groups(:three)
    g3.add_to_member(users(:two))
    g3.to_root(users(:two))
    assert_difference("AddGroupApplication.count",-1) do
      assert_difference("Member.count") do
        post  :accept,:id=>3,:group_id=>3
      end
    end
    assert_equal "接受了申请！",flash[:success]
    assert_redirected_to :action => "index"
  end
  #申请id传递 错误
  test "accept application error" do
    post :accept,:id=>3,:group_id=>3
    assert_redirected_to assigns(:group)
  end
 

  test "destroy" do
    assert_difference("AddGroupApplication.count") do
      xhr :post ,:apply,:add_group_application=>{:memo=>"我要加入"},:group_id=>1
    end
    add_group = AddGroupApplication.find_by_memo("我要加入")
    assert_difference("AddGroupApplication.count",-1) do
      xhr :delete ,:destroy,:id=>add_group.id,:group_id=>1
    end
    assert_redirected_to :action => "index"
  end
  
  test "destroy add group error" do
    assert_difference("AddGroupApplication.count",0) do
      xhr :delete ,:destroy,:id=>1,:group_id=>1
    end
    assert_equal "产生错误！",flash[:error]
    assert_redirected_to :action => "index"
  end

 
  
  test "apply add group" do
    assert_difference("AddGroupApplication.count") do
      xhr :post ,:apply,:add_group_application=>{:memo=>"我要加入"},:group_id=>1
    end
  end
end
