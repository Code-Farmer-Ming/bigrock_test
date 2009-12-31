require 'test_helper'

class RecommendsControllerTest < ActionController::TestCase
  def setup
    @userone=users(:one)
    login_as(@userone)
  end


  test "should get new" do
    xhr :get ,:new,:recommendable_type=>"Piecenews",:recommendable_id=>1
    assert_response :success
  end

  test "should create recommend" do
    assert_difference('Recommend.count') do
      xhr :post, :create, :recommend => { :memo=>"我推荐这个",:recommendable_type=>"Piecenews",:recommendable_id=>1}
    end

    assert assigns(:recommend)
  end

  test "should destroy recommend" do
    assert_difference('Recommend.count', -1) do
      xhr :delete, :destroy, :id => recommends(:one).to_param
    end

 
  end
end
