require 'test_helper'

class BaseInfosControllerTest < ActionController::TestCase
  def setup
    login_as(users(:two))
  end
  
  test "set description" do
    xhr :post ,:set_self_description ,:value=>"ok"
    assert_response :success
    assert_equal "ok",users(:two).base_info.reload.self_description
  end
  test "edit base_info" do
    put :update,:base_info=>{:user_name=>"alan"}
    assert_redirected_to new_user_pass_path(users(:two))
  end
end