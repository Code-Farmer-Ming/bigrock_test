
class AccountController < ApplicationController
  before_filter :check_login?,:except=>[:ajax_login,:get_news,:login,:ajax_login,:new,:create,:forget_password,:reset_password,:show,:check_email]
  
  def new
    @page_title ="注册"
    @user= User.new
    @user.nick_name = ""
    @user.email = params[:email] if params[:email]
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @user }
    end
  end
  #保存
  def create
    @user = User.new(params[:user])
    alias_user = User.new(params[:user])
    alias_user.email = "alias_email"+ alias_user.email
    alias_user.nick_name ="马甲"
    @user.aliases << alias_user
    resume = Resume.new()
    resume.user_name = @user.nick_name
    resume.is_current = true
    @user.setting = UserSetting.new
    @user.is_active = true
    @user.resumes << resume
    respond_to do |format|
      if @user.save
        session[:user]=@user
        format.html {  flash[:success] = '恭喜你注册你成功';redirect_to(account_path()) }
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
      @news = @user.my_follow_company_news.paginate :page => params[:page]#,:per_page=>2
    else
      @news = Piecenews.paginate :page => params[:page],:order=>"news.created_at desc"#,:per_page=>2
    end
    render :partial=>"news/news_short_info",:collection=>@news,:locals=>{:show_icon=>true}
  end
 
  def show
    @user= current_user
    if @user
      @page_title =" #{@user.name} 首页"
      @news = @user.my_follow_company_news.find(:all,:limit=>20)
      @topics = @user.my_follow_group_topics.find(:all,:limit=>20)
      @logs = @user.my_follow_log_items.find(:all,:limit=>10,:order=>"created_at desc");
      @my_topics = @user.my_topics.find(:all,:limit=>20)
      @join_topics =  @user.join_topics.find(:all,:limit=>20)
    else
      @page_title ="首页"
      @news = Piecenews.find(:all,:limit=>20,:order=>"news.created_at desc")
      @topics = Topic.group_topics.find(:all,:limit=>20,:order=>"topics.last_comment_datetime desc")
      @logs = LogItem.find(:all,:limit=>10,:order=>"created_at desc");
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
      user= User.find_by_email(params[:email])
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
        user.text_password_confirmation=params[:text_password_confirmation]
        if  user.text_password!= user.text_password_confirmation
          flash[:notice] = "两次输入密码不同！"
        else
          if user.save && @token.destroy
            flash[:success] = "密码设置成功请登录！"
            redirect_to login_account_path()
          end
        end
      end
    else
      flash[:error] = "重设密码链接错误！"
      #TODO: 要定向到专门的错误信息显示页面
      redirect_to(login_account_path())
    end
  end
  
  def set_password
    @page_title ="设置密码"
    @user = current_user
    if request.put?
      if params[:old_password] && User.login(@user.email, params[:old_password])[0]!="成功"
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
    @page_title ="设置资料查看权限"
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
    @page_title ="权限设置"
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
    @page_title ="基本设置"
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
    friend= User.find(params[:friend_id])
    current_user.friends_user << friend
    current_user.my_follow_users << friend
 
    respond_to do |format|
      format.js{
        render :update do |page|
          page[dom_id(friend,"operation")].replace_html render(:partial=>"users/operation",:object=>friend)
          page[dom_id(friend,"operation")].visual_effect(:highlight)
        end
      }
    end
  end
  
  def destroy_friend
    @user = User.find(params[:friend_id])
    #    @friend =current_user.friends.find_by_friend_id(params[:friend_id])
    respond_to do |format|
      if current_user.friends_user.delete(@user) && current_user.my_follow_users.delete(@user)
        format.html {redirect_to friends_user_path(current_user,:page=>params[:page]) }
        format.js # js
      end
    end
  end

  #检查email是否存在
  def check_email
    if (User.find_all_by_email(params[:value]).size==0)
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
    state = User.login(email, password)
    session[:user] = nil
    if state[0]=="成功"
      session[:user] = state[1]
      if auto_login
        cookies[:auto_login_user_id]= {:value=>state[1].id, :expires => 1.month.from_now}
      end
    else
      #返回失败的原因
      if (state[0].index("不存在"))
        state[0] += ",<a href=#{new_account_path(:email=>email)}>那现在注册吧！</a>"
      else
        state[0] += ",<a href=#{forget_password_account_path(:email=>email)}>取回密码！</a>"
      end
    end
    state[0]
  end
end
