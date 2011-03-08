require 'test_helper'

class ColleaguesControllerTest < ActionController::TestCase

  test "should get index" do
    login_as(users(:one))
    get :index,:user_id=>users(:one).to_param
    assert_response :success
    assert_not_nil assigns(:colleeagus)
  end

#  test "should destroy colleague" do
#    login_as(users(:one))
#    assert_difference('Colleague.count', -1) do
#      delete :destroy, :id => colleagues(:one).to_param
#    end
#
#    assert_redirected_to colleagues_path
#  end
end
