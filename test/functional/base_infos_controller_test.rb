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
end