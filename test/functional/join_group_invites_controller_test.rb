require 'test_helper'

class JoinGroupInvitesControllerTest < ActionController::TestCase
  def setup
    login_as(users(:user_016))
  end
  # Replace this with your real tests.
  test "index" do
    get :index 
    assert_response :success
  end
  test "accept" do
    assert_difference("Member.count") do
      post :accept, :id=>requisitions(:req_004).id
    end
    assert_redirected_to :action => "index"
  end
  test "destroy" do
    assert_difference("JoinGroupInvite.count",-1) do
      delete :destroy, :id=>requisitions(:req_004).id
    end
    assert_redirected_to :action => "index"
  end
end
