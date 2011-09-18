require 'test_helper'
 
class AccountControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  def setup
    @controller = AccountController.new
    @request    = ActionController::TestRequest.new
    @response   = ActionController::TestResponse.new
  end

  test "index" do
    get :index
    assert_response :success
  end
  
  test "show" do
    login_as(users(:one))
    get :show
    assert_response :success
  end
 

  test "show with not login" do
    get :show
    assert_redirected_to login_account_path(:reurl=>account_url())
  end
 
  test "new" do
    get :new
    assert_response :success
  end

  test "new with request company id" do
    get :new ,:request_company_id=>1
    assert_not_nil assigns(:maybe_know_colleagues )
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
    assert_redirected_to  edit_account_base_info_path()
    assert User.find_all_by_email(email).size>0
    
    assert_equal assigns(:user).alias.parent, assigns(:user)
    #自己关注自己
    assert_difference "assigns(:user).my_follow_log_items.count" do
      assigns(:user).set_signature("ok")
    end
  end

  test "create with reurl" do
    email ="zhang@ming1.com"
    assert_difference("User.count",2) do
      post  :create ,:user=>{
        :email=>email,
        :nick_name=>"nick_name",
        :text_password=>"ming12",
        :text_password_confirmation=>"ming12"
      },
        :reurl=>'/groups'
    end
    #    assert_redirected_to '/groups'
  end

  test "create with invite" do
    email ="zhang@ming1.com"
    assert_difference("User.count",2) do
      post  :create ,:user=>{
        :email=>email,
        :nick_name=>"nick_name",
        :text_password=>"ming12",
        :text_password_confirmation=>"ming12"
      } ,
        :request_user_id=>1,
        :request_company_id=>1
    end
    #    assert_redirected_to  new_user_pass_path(assigns(:user),:request_user_id=>1,:request_company_id=>1)
    assert User.find_all_by_email(email).size>0

    assert_equal assigns(:user).alias.parent, assigns(:user)
  end
  
  test "diff password create" do
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
    assert_equal(one.id, session[:user])
  end

  test "login_auto" do

    get :login
    assert_response :success
    one=users(:one)

    post :login,:email=>one.email,:password=>"MyString",:auto_login=>true
    assert_equal(one.id, session[:user])
    assert_equal one.id.to_s,cookies["auto_login_user_id"]
  end

  test "login_out" do
    get :login
    assert_response :success
    one=users(:one)
    post :login,:email=>one.email,:password=>"MyString"
    assert_equal(one.id, session[:user])
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
    assert_not_nil flash[:success]

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

  test "set user state" do
    login_as(users(:one))
    for i in 0..1
      xhr :post,:set_user_state,:state=>User::STATE_TYPES.keys[i].to_s
      assert_equal User::STATE_TYPES.keys[i].to_s,users(:one).reload().state
    end
    xhr :post,:set_user_state
    assert_equal User::STATE_TYPES.keys[0].to_s,users(:one).reload().state
  end
  
  test "judged" do
    login_as(users(:one))
    get :judged_colleagues
    assert_response :success
    assert_not_nil assigns(:judged)
  end
  
  test "unjudge colleague" do
    login_as(users(:one))
    get :unjudge_colleagues
    assert_response :success
    assert_not_nil assigns(:unjudge_colleagues)
  end
  
  test "judged company" do
    login_as(users(:one))
    get :judged_company
    assert_response :success
    assert_not_nil assigns(:judged_companies)
  end
  
  test "unjudge company" do
    login_as(users(:one))
    get :unjudge_company
    assert_response :success
    assert_not_nil assigns(:unjudge_companies)
  end

  test "published jobs" do
    login_as(users(:one))
    get :published_jobs
    assert_response :success
    assert_not_nil assigns(:jobs)
  end

  test "published job applicants" do
    login_as(users(:one))
    get :published_job_applicants
    assert_response :success
    assert_not_nil assigns(:applicants)
  end

  test "job applicants" do
    login_as(users(:one))
    get :job_applicants
    assert_response :success
    assert_not_nil assigns(:applicants)
  end

  test "need jobs"  do
    login_as(users(:one))
    get :need_jobs
    assert_response :success
    assert_not_nil assigns(:need_jobs)
  end

  test "search" do
    get :search ,:type=>"group",:search=>"test"
    assert_redirected_to search_groups_path(:search=>"test")
    get :search ,:type=>"job",:search=>"test"
    assert_redirected_to search_jobs_path(:search=>"test")
    get :search ,:type=>"company",:search=>"test"
    assert_redirected_to search_companies_path(:search=>"test")
  end

 
end
