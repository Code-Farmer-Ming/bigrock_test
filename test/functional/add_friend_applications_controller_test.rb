require 'test_helper'
#TODO 测试不全 需添加
class AddFriendApplicationsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    login_as(users(:one))
  end
  test "index" do
    get :index
    assert_not_nil assigns(:add_friend_applications)
  end

  test "create" do
    ActionMailer::Base.deliveries.clear

    assert_difference("AddFriendApplication.count") do
      xhr :get ,:new,:user_id=>3
      xhr :post ,:create,:add_friend_application=>{:memo=>"apply"},:user_id=>3
    end
    #    assert_tag :tag => "span", :attributes => { :class => "hot_text" }

  end
  
  test "destroy" do
    user= User.find(1)
    assert_equal 1, user.add_friend_applications.size

    delete :destroy,:id=>1
    assert_equal 0, user.add_friend_applications.size
  end
  #  test "accept" do
  #    assert_difference("AddFriendApplication.count") do
  #      xhr :get ,:apply,:respondent_id=>12
  #      xhr :post ,:apply,:add_friend_application=>{:respondent_id=>12,:memo=>"apply"}
  #    end
  #    login_as(users(:user_012))
  #    assert_difference("AddFriendApplication.count",-1) do
  #      post :accept ,:id => assigns(:add_friend).id
  #    end
  #
  #    users(:one).reload
  #    assert users(:one).friend_users.exists?(users(:user_012))
  #    assert !users(:user_012).friend_users.exists?(users(:one))
  #    assert_equal "添加成功！",flash[:success]
  #  end
  #
  #  test "accept each" do
  #    assert_difference("AddFriendApplication.count") do
  #      xhr :get ,:apply,:respondent_id=>12
  #      xhr :post ,:apply,:add_friend_application=>{:respondent_id=>12,:memo=>"apply"}
  #    end
  #    login_as(users(:user_012))
  #    assert_difference("AddFriendApplication.count",-1) do
  #      post :accept ,:id => assigns(:add_friend).id,:commit=>"接受并加其为好友"
  #    end
  #    users(:one).reload
  #    users(:user_012).reload
  #    assert users(:one).friend_users.exists?(users(:user_012))
  #    assert users(:user_012).friend_users.exists?(users(:one))
  #    assert_equal "添加成功！",flash[:success]
  #
  #  end
end