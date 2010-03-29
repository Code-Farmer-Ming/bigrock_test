require 'test_helper'

class AccountControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end
  
  test "show" do
    login_as(users(:one))
    get :show
    assert_response :success
  end
  test "set password" do
    login_as(users(:one))
    get :set_password
    assert_response :success
  end
  test "show with not login" do
    get :show
    assert_response :success
  end
 
  test "new" do
    get :new
    assert_response :success
  end
  
  test "create" do
    email ="zhang@ming1.com"
    assert_difference("User.count",2) do
      post  :create ,:user=>{
        :email=>email,
        :nick_name=>"nick_name",
        :text_password=>"ming12",
        :text_password_confirmation=>"ming12"
      }
    end
    assert User.find_all_by_email(email).size>0
    assert_equal  1, assigns(:user).aliases.count
    assert_equal assigns(:user).aliases[0].parent, assigns(:user)
  end
  
  test "diff_password_create" do
    email ="zhang@ming.com1"
    post  :create ,:user=>{
      :email=>email,
      :text_password=>"diff_password",
      :text_password_confirmation=>"ming12"
    },:name=>"name123"
    assert User.find_all_by_email(email).size==0
  end


  test "login ok" do
    get :login
    assert_response :success
    one=users(:one)
    post :login,:email=>one.email,:password=>"MyString"
    assert_equal(one.id, session[:user].id)
  end

  test "login_auto" do

    get :login
    assert_response :success
    one=users(:one)

    post :login,:email=>one.email,:password=>"MyString",:auto_login=>true
    assert_equal(one.id, session[:user].id)
    assert_equal one.id.to_s,cookies["auto_login_user_id"]
  end

  test "login_out" do
    get :login
    assert_response :success
    one=users(:one)
    post :login,:email=>one.email,:password=>"MyString"
    assert_equal(one.id, session[:user].id)
    get :logout
    assert_nil(session[:user])
    assert_nil(cookies[:user])
  end

  test "login_fail" do
    get :login
    assert_response :success
    one=users(:one)
    post :login,:email=>one.email,:password=>"MyString1"
    assert flash[:error].index("密码错误")
    post :login,:email=>one.email+"ee",:password=>"MyString1"
    assert flash[:error].index("不存在")
 
  end

  test "forget_password" do
    Token.destroy_all
    get :forget_password
    assert_response :success
    two=users(:two)

    post :forget_password,:email=>two.email
    assert_not_nil flash[:success]
    assert_not_nil(ActionMailer::Base.deliveries[0])
    
    post :forget_password,:email=>two.email
    
    assert_equal 1, Token.find_all_by_user_id_and_action(two.id,Token::ACTION_RECOVERY).size

    two.email+="ee"
    post:forget_password,:email=>two.email
    assert_equal(flash[:notice],"#{two.email}邮件地址不存在！")

  end

  test "reset_password" do
    token_one=tokens(:one)
    token_two=tokens(:two)
    get :reset_password,:token=>token_one.value
    assert_response :success
    assert_nil(flash[:notice])
    post :reset_password,:text_password=>"ok",:text_password_confirmation=>"ok",:token=>token_one.value
    assert_equal(flash[:success],"密码设置成功请登录！")

    assert_nil(Token.find_by_id(token_one.id))
    assert_equal User.login(token_one.user.email,"ok")[0],0

    get :reset_password,:token=>token_one.value+'i'

    assert_equal(flash[:error],"重设密码链接错误！")

    get :reset_password,:token=>token_two.value
    assert_response :success
    post :reset_password,:text_password=>"ok1",:text_password_confirmation=>"ok2",:token=>token_two.value
    assert_equal(flash[:notice],"密码 两次不同")
    assert_equal User.login(token_one.user.email,"ok1")[0],-2

  end
  #TODO 应该写每一项值更改的测试
  #  test "set_resume_visibility" do
  #    login_as(users(:two))
  #    get :set_resume_visibility
  #    assert_response :success
  #    assert_equal UserSetting::VISIBILITY_TYPES[0], assigns(:user).setting.img_visibility
  #    assert assigns(:user).setting.can_visibility?("img_visibility", users(:three))
  #    put :set_resume_visibility,:user_setting=>{:img_visibility=>UserSetting::VISIBILITY_TYPES[1]}
  #    assert_equal "更新成功", flash[:success]
  #    assert assigns(:user).setting.can_visibility?("img_visibility", users(:one))
  #    assert !assigns(:user).setting.can_visibility?("img_visibility", users(:three))
  #    assert_equal UserSetting::VISIBILITY_TYPES[1], assigns(:user).setting.img_visibility
  #  end
  
  test "set_user_auth_apply_friend" do
    login_as(users(:one))
    get :set_user_auth
    assert_response :success
    assert_equal UserSetting::APPLY_FRIEND_TYPES[0], assigns(:user).setting.apply_friend_auth
    put :set_user_auth,:user_setting=>{:apply_friend_auth=>UserSetting::APPLY_FRIEND_TYPES[1]}
 
    assert_equal UserSetting::APPLY_FRIEND_TYPES[1], assigns(:user).setting.apply_friend_auth
  end

  test "set_base_info_chang_password_bad" do
    login_as(users(:one))

    put :set_password,:old_password=>"test",:new_password=>"new_password"
    assert_not_nil  flash[:error]  
  end
  
  test "set_base_info_chang_password_ok" do
    login_as(users(:one))

    put :set_password,:old_password=>"MyString",:user=>{:text_password=>"new_password",:text_password_confirmation=> "new_password"}
    assert_not_nil flash[:success]
    get :logout
    get :login
    one=users(:one)
    post :login,:email=>one.email,:password=>"new_password"
    assert_equal(one.id, session[:user].id)
    #get :set_base_info
    # xhr :post,attachments_url(),:Filedata=>test_uploaded_file("sorry.jpg","img/jpg"),:type=>"UserIcon"
    #post :set_base_info, :uploaded_file_id=>assert_
    #assert_equal "sorry.jpg",session[:user].icon.filename
  
  end
  test "set_base_info_chang_email" do
    login_as(users(:one))
    get :set_base_info
    put :set_base_info,:user=>{:email=>"new_email"}
    assert_equal "new_email",assigns(:user).email
  end
  test "add_friend_and_destroy" do
    one= users(:one)

    login_as(users(:one))
    post :add_friend ,:friend_id=>2
    
    assert one.friends_user.exists?(2),"添加好友失败"
    assert one.my_follow_users.exists?(users(:two)),"关注失败"
    
    post :destroy_friend ,:friend_id=>2
    assert !one.friends_user.exists?(2),"删除好友失败"
    assert_not_nil User.find_by_id(users(:two))
    assert !one.my_follow_users.exists?(users(:two)),"取消关注失败"
  end
  test "attention_user_and_cancel_attention" do
    one= users(:one)
    login_as(users(:one))
    post :attention ,:target_id=>2,:target_type=>users(:two).class
    assert one.my_follow_users.exists?(users(:two)),"关注"

    delete :destroy_attention  ,:target_id=>2,:target_type=>users(:two).class
    assert !one.my_follow_users.exists?(users(:two)),"取消关注失败"
  end

  test "attention_company_and_cancel" do
    one= users(:one)
    login_as(users(:one))

    post :attention ,:target_id=>2,:target_type=>companies(:two).class
    assert one.my_follow_companies.exists?(companies(:two)),"关注"

    delete :destroy_attention ,:target_id=>2,:target_type=>companies(:two).class
    assert !one.my_follow_companies.exists?(companies(:two)),"取消关注失败"
  end
  test "set_alias" do
    login_as(users(:one))
    get :set_alias
    assert_response :success
  end
  
  test "set_alias post" do
    login_as(users(:one))
    put :set_alias,:user=>{:nick_name=>"new alias"}
    assert_equal "new alias" ,assigns(:alias).nick_name
  end
  test "set user state" do
    login_as(users(:one))
    for i in 0..2
      xhr :post,:set_user_state,:state=>User::STATE_TYPES.keys[i].to_s
      assert_equal User::STATE_TYPES.keys[i].to_s,users(:one).reload().state
    end
    xhr :post,:set_user_state
    assert_equal User::STATE_TYPES.keys[0].to_s,users(:one).reload().state
  end
end
