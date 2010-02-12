require 'test_helper'

class MsgsControllerTest < ActionController::TestCase
  def setup
    login_as(users(:one))
  end
  # Replace this with your real tests.
  test "show" do
    get :show ,:id=>1
    assert_response :success
  end
  
  test "show with error id" do
    get :show ,:id=>10
    assert_response 302
  end

  test "index" do
    get :index
    assert_response :success
  end
  test "new" do
    get :new
    assert_response :success
  end

  test "new with write_to" do
    user_two = users(:two)
    get :new,:write_to=>user_two.to_param
    assert_response :success
    assert_equal "#{user_two.id}", assigns(:write_to).id.to_s
  end
  
  test  "create" do
    assert_difference("Msg.count",2) do
      post :create, :msg=>{:title => "xc",:content=>"xccc",:sendees=>"2 3"},:alias=>1
    end
  end

  test "create with alias" do
    assert_difference("Msg.count",2) do
      post :create, :msg=>{:title => "xc",:content=>"xccc",:sendees=>"2 3"},:alias=>16
    end
  end
end
