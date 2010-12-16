require 'test_helper'

class ColleaguesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:colleagues)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create colleague" do
    assert_difference('Colleague.count') do
      post :create, :colleague => { }
    end

    assert_redirected_to colleague_path(assigns(:colleague))
  end

  test "should show colleague" do
    get :show, :id => colleagues(:one).to_param
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => colleagues(:one).to_param
    assert_response :success
  end

  test "should update colleague" do
    put :update, :id => colleagues(:one).to_param, :colleague => { }
    assert_redirected_to colleague_path(assigns(:colleague))
  end

  test "should destroy colleague" do
    assert_difference('Colleague.count', -1) do
      delete :destroy, :id => colleagues(:one).to_param
    end

    assert_redirected_to colleagues_path
  end
end
