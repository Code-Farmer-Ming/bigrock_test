require 'test_helper'

class SettingsControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    login_as(users(:one))
  end
  test "set_alias" do
    get :alias
    assert_response :success
  end


  test "set_alias post" do
    put :alias,:user=>{:nick_name=>"new alias"}
    assert_equal "new alias" ,assigns(:alias).nick_name
  end

  test "set_base_info_chang_email" do
    get :base_info
    put :base_info,:user=>{:email=>"new_email"}
    assert_equal "new_email",assigns(:user).email
  end

  test "chang_password_bad" do
    put :password,:old_password=>"test",:new_password=>"new_password"
    assert_not_nil  flash[:error]
  end

  test "chang_password_ok" do
    put :password,:old_password=>"MyString",:user=>{:text_password=>"new_password",:text_password_confirmation=> "new_password"}
    assert_not_nil flash[:success]
  end
  
  test "auth" do
    get :auth
    assert_response :success
  end

  test "put auth" do
    put :auth ,:user_setting=>{:apply_friend_auth=>"ok"}
    assert_equal "ok",users(:one).setting.apply_friend_auth
  end

  test "put auth apply friend" do
    put :auth,:user_setting=>{:apply_friend_auth=>UserSetting::APPLY_FRIEND_TYPES[1]}
    assert_equal UserSetting::APPLY_FRIEND_TYPES[1], assigns(:user).setting.apply_friend_auth
  end

  test "alias" do
    get :alias
    assert_response :success
  end
  
  test "put alias" do
    put :alias,:user=>{:nick_name=>"新名字"}
    assert_equal "新名字",users(:one).alias.name,flash[:error]
  end
end
