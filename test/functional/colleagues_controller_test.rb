require 'test_helper'

class ColleaguesControllerTest < ActionController::TestCase
  def setup
    login_as(users(:one))
  end
  test "should get index" do
    get :index,:user_id=>users(:one).to_param
    assert_response :success
    assert_not_nil assigns(:colleeagus)
  end

  test "confirm" do
    Colleague.create(:user_id=>1,:colleague_id=>2,:my_pass_id=>1,:colleague_pass_id=>2)
    user1= users(:one)
    assert_difference "user1.colleagues.count",1 do
      assert_difference "user1.need_comfire_colleagues.count",-1 do
        assert_difference "user1.undetermined_colleagues.count",-1 do
          xhr :post,:confirm,:id=>user1.undetermined_colleagues.first
        end
      end
    end
  end

  test "cancel" do
    Colleague.create(:user_id=>1,:colleague_id=>2,:my_pass_id=>1,:colleague_pass_id=>2)
    user1= users(:one)
    user1.undetermined_colleagues.first.confirm
    assert_difference "user1.colleagues.count",-1 do
      assert_difference "user1.need_comfire_colleagues.count",1 do
        xhr :post,:cancel,:id=>user1.colleagues.first
      end
    end
  end
end
