
class AccountController < ApplicationController
  before_filter :check_login?,:except=>[:ajax_login,:get_news,:login,:ajax_login,:new,:create,:forget_password,:reset_password,:show,:check_email]
  
  def new
    flash[:notice] = "请先快速的注册一下" if params[:request_company_id]
    @page_title ="注册"
    @user= User.new
    @user.nick_name = ""
    @user.email = params[:email]
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end
  #保存
  def create
    @user = User.new(params[:user])
    respond_to do |format|
      if @user.save
        invite_user = User.real_users.find_by_id(params[:request_user_id]) unless !params[:request_user_id]
        if invite_user#相互加为好友
          invite_user.add_friend(@user)
          @user.add_friend(invite_user)
        end
        session[:user]=@user
        format.html {  flash[:success] = '恭喜你注册你成功'
          redirect_to( 
            params[:request_company_id] ?
              new_user_resume_pass_path(@user,@user.current_resume,:request_user_id=>params[:request_user_id],:request_company_id=>params[:request_company_id])  : (params[:reurl] || account_path())) }
        format.xml  { render :xml => @user, :status => :created, :location => @user }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @user.errors, :status => :unprocessable_entity }
      end
    end
  end
  #ajax 获取信息
  def get_news
    if @user=current_user
      @news = @user.my_follow_company_news.paginate :page => params[:page],:per_page=>4
    else
      @news = Piecenews.paginate :page => params[:page],:order=>"news.created_at desc",:per_page=>4
    end
    render :partial=>"news/news_short_info",:collection=>@news,:locals=>{:show_icon=>true}
  end
 
  def show
    @add_friend_request_size = 0
    @join_group_invites_size =0
    @user= current_user
    if @user
      @page_title =" #{@user.name} 的首页"
      #      @news = @user.my_follow_company_news.find(:all,:limit=>6)
      @topics = @user.my_follow_group_topics.find(:all,:limit=>20)
      @logs = @user.my_follow_log_items.find(:all,:limit=>10,:order=>"created_at desc");
      @my_topics = @user.my_created_topics.all(:limit=>20)
      @join_topics =  @user.reply_topics.find(:all,:limit=>20)
      @add_friend_request_size = @user.add_friend_applications.size
      @join_group_invites_size = @user.join_group_invites.size
    else
      @page_title ="首页"
      @page_keywords="个人 公司 简历 信息 招聘 职位 评分 公司评分 个人评分 待遇 环境 小组"
      #      @news = Piecenews.newly.all(:limit=>4)
      @hot_topics = Topic.hot.since(7.days.ago).limit(10)
      @logs = LogItem.find(:all,:limit=>8,:order=>"created_at desc");
      @salary_best_companies =  Company.order_by_salary.limit(6)
      @condition_best_companies =  Company.order_by_condition.limit(6)
    end
  end
  
  
  def my_topics
    @user= current_user
    case params[:type]
    when "all"
      @page_title = "最新的话题"
      @topics = @user.my_follow_group_topics.paginate :all, :page => params[:page]
    when "join"
      @page_title = "我参与的话题"
      @topics =  @user.reply_topics.paginate :all, :page => params[:page]
    else
      @page_title = "我创建的话题"
      @topics = @user.my_created_topics.paginate :all , :page => params[:page]
    end
  end

  #登录
  def login
    @page_title ="登录"
    if request.post?
      reurl = params[:reurl]
      result_text = user_login(params[:email],params[:password],params[:auto_login])
      if result_text=="成功"
        redirect_to reurl.blank? ?  account_path() : reurl
      else
        flash.now[:error] = result_text
        render :action=>"login"
      end
    else
      #调用 js的方式显示登录页面
      respond_to do |format|
        format.html {}
        format.js{ render :update do |page|
            page << "Lightbox.show('/account/ajax_login')"
          end }
      end
    end
  end
  
  def ajax_login
    if request.post?
      result_text = user_login(params[:email],params[:password],params[:auto_login])
      respond_to do |format|
        if result_text=="成功"
          format.js{ render :update do |page|
              page << "window.location.reload();Lightbox.close()"
            end }
        else
          flash.now[:error] = result_text
          format.js{ render :update do |page|
              page["error_msg_login"].replace_html( render(:partial=>"comm_partial/flash_msg"))
            end }
        end
        format.html{ redirect_to :action=>"login" }
      end
    end
  end
  #登出
  #TODO:退出时 返回到推出前所在的页面，不是退到Index页面
  def logout
    cookies.delete(:auto_login_user_id)
    session[:user] = nil
    redirect_to(:action=>"index")    
  end
  #begin 一些设置功能
  #
  #忘记密码
  def forget_password
    @page_title ="取回密码"
    if request.post?
      user= User.real_users.find_by_email(params[:email])
      if user
        Token.destroy_all(:user_id=>user,:action=>Token::ACTION_RECOVERY)
        token=Token.new(:user=>user,:action=>Token::ACTION_RECOVERY)
        if token.save
          MailerServer.deliver_forget_password(token)
          params[:email] = nil
          flash.now[:success] = "重设密码链接，已发送到#{user.email}邮箱！"
        end
      else
        flash.now[:notice] = "#{params[:email]}邮件地址不存在！"
      end
    end
  end
  #重设密码
  def reset_password
    @page_title ="设置新密码"
    @token=Token.find_by_action_and_value(Token::ACTION_RECOVERY,params[:token])
    if !@token.nil?
      if request.post?
        user= @token.user
        user.text_password=params[:text_password]
        user.text_password_confirmation = params[:text_password_confirmation]
        if user.save && @token.destroy
          flash[:success] = "密码设置成功请登录！"
          redirect_to login_account_path()
        else
          flash[:notice] = user.errors.full_messages.to_s
        end
      end
    else
      flash[:error] = "重设密码链接错误！"
      redirect_to(login_account_path())
    end
  end
  
  def set_password
    @page_title ="设置密码"
    @user = current_user
    if request.put?
      if params[:old_password] && User.login(@user.email, params[:old_password])[0]!=0
        flash.now[:error] = "原密码错误!"
      else
        if @user.update_attributes(params[:user])
          flash.now[:success] = "设置成功!"
        end
      end
    end
    respond_to do |format|
      format.html {}# show.html.erb
      format.xml  { render :xml => @user }
    end
  end
  #设置 档案 可视的权限
  def set_resume_visibility
    @user =  current_user
    if  !request.post?
      return
    end
    @visible_set = params[:user_setting].collect { |e| e }[0][1]
    @visible_set_index = UserSetting::VISIBILITY_TYPES.index(@visible_set)
    @visible_set_field = params[:user_setting].collect { |e| e }[0][0]
    @is_right= (UserSetting::VISIBILITY_TYPES.index(@visible_set)>-1) &&
      @user.setting.update_attributes(params[:user_setting])
  end
  #用户隐私设置
  def set_user_auth
    @page_title ="用户隐私设置"
    @user = current_user
    if request.put?
      if @user.setting.update_attributes(params[:user_setting])
        flash[:success] = "设置成功!"
      end
    end
  end
  #设置用户的状态
  def set_user_state
    current_user.update_attribute("state", params[:state] || User::STATE_TYPES.keys[0].to_s())
    new_state = params[:state] || User::STATE_TYPES.keys[0].to_s
    new_state_content =User::STATE_TYPES[new_state.to_sym]
    LogItem.create(:owner=>current_user,:log_type=>"state_change",:changes=>new_state,:operation=>"create")
    render :update do |page|
      page.select(".current_user_state").each do |item|
        page << "value.title = '#{new_state_content}';"
        page << "value.className ='user_state_at_icon user_state_#{new_state} current_user_state';"
      end
    end
  end

  def search
    @page_title ="基本设置1"
  end

  def set_base_info
    @page_title ="基本设置"
    @user = current_user
    if request.put?
      if params[:uploaded_file_id] && params[:uploaded_file_id]!=""
        @user.icon = UserIcon.find(params[:uploaded_file_id])
      end
      if @user.update_attributes(params[:user])
        flash[:success] = "设置成功!"
      end
    end
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
  end
  
  def set_alias
    @page_title ="马甲设置"
    @alias = current_user.aliases.first
    if request.put?
      if params[:uploaded_file_id] && params[:uploaded_file_id]!=""
        @alias.icon = UserIcon.find(params[:uploaded_file_id])
      end
      if @alias.update_attributes(params[:user])
        flash[:success] = "更新成功"
      end
    end
  end
  
  def add_friend
    friend= User.real_users.find(params[:friend_id])
    respond_to do |format|
      if current_user.add_friend(friend)
        format.js{
          render :update do |page|
            page[dom_id(friend,"operation")].replace_html render(:partial=>"users/operation",:object=>friend)
            page[dom_id(friend,"operation")].visual_effect(:highlight)
          end
        }
      else
        format.js {
          render :update do |page|
            flash.now[:error] = current_user.errors.full_messages.to_s
            page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
          end
        }
      end
    end
  end
  
  def destroy_friend
    @user =current_user.friend_users.find_by_id(params[:friend_id])
    respond_to do |format|
      if current_user.remove_friend(@user)
        format.html {redirect_to friends_user_path(current_user,:page=>params[:page]) }
        format.js {
          render :update do |page|
            page[dom_id(@user,"operation")].replace_html render(:partial=>"users/operation",:object=>@user)
            page[dom_id(@user,"operation")].visual_effect(:highlight)
          end
        }
      else
        format.html {redirect_to friends_user_path(current_user,:page=>params[:page]) }
        format.js {
          render :update do |page|
            flash.now[:error] = current_user.errors.full_messages.to_s
            page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
          end
        }
      end
    end
  end


  #检查email是否存在
  def check_email
    if (!User.exists?(["email=?",params[:value]]))
      render :text=> ""
    else
      render :text=> "邮件地址已经注册过了！如果忘记 " + "<a href='#{forget_password_account_path(:email=>params[:value])}'>找回密码</a>"
    end
  end

  #关注
  def attention
    target = params[:target_type].to_s.camelize.constantize
    target_object = target.find(params[:target_id])
    current_user.targets << target_object
    respond_to do |format|
      format.js{
        render :update do |page|
          page[dom_id(target_object,"operation")].replace_html render(:partial=>"#{target.base_class.to_s.pluralize.downcase}/operation",:object=>target_object)
          page[dom_id(target_object,"operation")].visual_effect(:highlight)
        end
      }
    end
  end
  #取消关注
  def destroy_attention
    target = params[:target_type].to_s.camelize.constantize
    target_object = target.find(params[:target_id])
    current_user.targets.delete(target_object)
    respond_to do |format|
      format.js{
        render :update do |page|
          page[dom_id(target_object,"operation")].replace_html render(:partial=>"#{target.base_class.to_s.pluralize.downcase}/operation",:object=>target_object)
          page[dom_id(target_object,"operation")].visual_effect(:highlight)
        end
      }
    end
  end

  #所有我关注对象的日志记录
  def follow_logs
    @page_title ="我所关注好友的动态"
    if params[:type]=="all" || params[:type]=="" || params[:type]==nil
      @log_items = current_user.my_follow_log_items.paginate :page => params[:page]
    else
      @log_items = current_user.my_follow_log_items.paginate_by_owner_type params[:type], :page => params[:page]
    end
  end

  def set_my_language
    unless [:post, :put].include?(request.method) then
      return render(:text => 'Method not allowed', :status => 405)
    end
    if !params[:value] || params[:value].blank?
      current_user.my_languages.current_language.cancel_current
      render :text => ""
    else
      if  current_user.my_language!=params[:value].strip
        current_user.my_languages << MyLanguage.new(:content=>params[:value],:is_current=>true)
      end
      render :text => CGI::escapeHTML(current_user.my_language)
    end
  end
  private

  #  def set_User_my_language
  #    unless [:post, :put].include?(request.method) then
  #      return render(:text => 'Method not allowed', :status => 405)
  #    end
  #    @item = User.find(params[:id])
  #    @item.update_attribute("my_language", params[:value])
  #    render :text => CGI::escapeHTML(@item.send("my_language").to_s+"-")
  #  end
  #执行登录操作
  def user_login(email,password,auto_login=false)
    code,user = User.login(email, password)
    session[:user] = nil
    if code==0
      session[:user] = user.id
      if auto_login
        cookies[:auto_login_user_id]= {:value=>user.id, :expires => 1.month.from_now}
      end
      "成功"
    else
      #返回失败的原因
      if (code==-1)
        "邮件不存在,<a href=#{new_account_path(:email=>email)}>那现在注册吧！</a>"
      else
        "密码错误,<a href=#{forget_password_account_path(:email=>email)}>取回密码！</a>"
      end
    end

  end
end
