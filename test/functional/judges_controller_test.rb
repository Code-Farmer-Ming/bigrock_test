require 'test_helper'

class JudgesControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    login_as(users(:one))
  end

  test "new" do
    xhr :get,:new,:user_id=>users(:two)
    assert_response :success
  end
  test "create" do
    user_1 = users(:one)
    user_1.passes.first.update_attributes(:end_date=>"2010-10-10")

    user_2 = users(:two)
    user_2.need_comfire_colleagues.first.confirm
    assert_difference("user_1.has_judge_them_colleagues.count") do
      assert_difference("user_1.not_judge_them_colleagues.count",-1) do
        assert_block("user_2.judges.count") do
          xhr :post,:create,:judge=>{:anonymous=>1,:description=>"不错的小伙",
            :creditability_value=>1,:eq_value=>1,:ability_value=>1},
            :my_tags=>"辖门",
            :user_id=>user_2.id
        end
      end
    end
    get  :index ,:user_id=>user_2.id
    assert_response :success
  end

  test "edit" do
    user1_judge_user2()
    user1=users(:one)
    get :edit,:id=>user1.judged.first
    assert_not_nil assigns(:judge)
    assert_response :success
  end

  test "update" do
    user1_judge_user2()
    user1=users(:one)
    put :update,:id=>user1.judged.first,:judge=>{:description=>"修改了"},:my_tags=>""
    assert_equal "修改了",user1.judged.first.description
  end

  test "destroy" do
    user1_judge_user2()
    user1=users(:one)
    assert_difference "user1.has_judge_them_colleagues.count",-1 do
      assert_difference "user1.not_judge_them_colleagues.count" do
        delete :destroy ,:id=>user1.judged.first
      end
    end
  end

  test "index default" do
    get :index,:user_id=>2
    assert_response :success
  end
  #  #对别人的评价
  #  test "index judged user" do
  #    get :judged
  #    assert_response :success
  #    assert_not_nil assigns(:judged)
  #  end
  #
  #  test "index judged company" do
  #    get :index ,:type=>"company"
  #    assert_response :success
  #    assert_not_nil assigns(:judged_companies)
  #  end
  def user1_judge_user2
    user_1 = users(:one)
    user_1.passes.first.update_attributes(:end_date=>"2010-10-10")

    user_2 = users(:two)
    user_2.need_comfire_colleagues.first.confirm

    xhr :post,:create,:judge=>{:anonymous=>1,:description=>"不错的小伙",
      :creditability_value=>1,:eq_value=>1,:ability_value=>1},
      :my_tags=>"辖门",
      :user_id=>user_2.id,
      :pass_id=>user_2.passes.first

  end
  
end
