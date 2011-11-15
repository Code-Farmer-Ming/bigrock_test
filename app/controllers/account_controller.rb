
class AccountController < ApplicationController
  before_filter :check_login?,:except=>[:index,:login,:search,:new,:create,:forget_password,:reset_password,:check_email]

  def index
    @page_title ="首页"
    @page_keywords="公司,简历,工作,职位,求职,热门职位,找工作,公司信息,公司工作待遇,在线简历,电子简历,评分,待遇,环境,小组,最新话题"
    @page_description = "谁靠谱网提供更真实、客观、公正、有效的公司环境、待遇的评价、评分和公司详细信息.拥有更真实和多维度的在线简历。招聘职位，求职的平台"
  
    #    @newly_topics = Topic.order_by_last_comment.limit(16)
    @logs = LogItem.find(:all,:limit=>8,:order=>"created_at desc");
    @need_jobs = NeedJob.limit(6).order("created_at desc")
    @jobs = Job.limit(6).order("created_at desc")
  end
  
  def new
    @page_title ="注册"
    @user= User.new
    @user.nick_name = ""
    @user.email = params[:email]

    if params[:request_company_id]
      request_company = Company.find_by_id(params[:request_company_id])
      @maybe_know_colleagues = request_company.mybe_know_employees if request_company
      #      flash[:notice] = "请先快速的注册，马上就能对您的朋友进行评价了"
    end
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
        @user.add_attention(@user)#关注自己
        invite_user = User.real_users.find_by_id(params[:request_user_id]) unless !params[:request_user_id]
        if invite_user#相互加关注
          invite_user.add_attention(@user)
          @user.add_attention(invite_user)
        end
        set_user_session(@user)
        format.html {
          flash[:success] = '恭喜注册成功,完善一下资料吧。'
          #          if not params[:request_company_id].to_s.blank?
          redirect_to(edit_account_base_info_path(:request_company_id=>params[:request_company_id],:reurl=>params[:reurl]))
          #          else
          #            redirect_to((params[:reurl] || user_path(@user)))
          #          end
        }
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
    @join_group_invites_size =0
    @unread_job_apply_size =0
    @user= current_user
    @page_title =" #{@user.name} 的首页"

    if params[:type].blank? || params[:type]=="all"
      @logs = current_user.my_follow_log_items.paginate :page => params[:page]
    elsif params[:type]=="colleague"
      @logs = current_user.colleague_logs.paginate :page => params[:page]
    elsif params[:type]=="friend"
      @logs = current_user.friend_logs.paginate :page => params[:page]
    elsif params[:type]=="group"
      @logs = current_user.group_logs.paginate :page => params[:page]
    elsif params[:type]=="company"
      @logs = current_user.following_company_logs.paginate :page => params[:page]
    end
    #    @topics = @user.my_follow_group_topics.find(:all,:limit=>20)
    #    @my_topics = @user.my_created_topics.all(:limit=>20)
    #    @join_topics =  @user.reply_topics.find(:all,:limit=>20)
 
    @join_group_invites_size = @user.join_group_invites.count
    @unread_job_apply_size = @user.unread_published_job_applicants.count
    @unread_broadcast_count =  current_user.user_broadcasts.count
    @by_apply_colleague_count = current_user.by_apply_colleagues.count
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
      respond_to do |format|
        if result_text=="成功"
          format.html {redirect_to reurl.blank? ?  account_path() : reurl}
          format.js{
            render :update do |page|
              page << "window.location.reload();Lightbox.close()"
            end
          }
        else
          flash.now[:error] = result_text
          format.html{
            render :action=>"login"
          }
          format.js{
            render :update do |page|
              page["error_msg_login"].replace_html( render(:partial=>"comm_partial/flash_msg"))
            end }
        end
      end
    else #get的时候
      respond_to do |format|
        format.html{}
        format.js{#调用 js的方式显示登录页面
          if params[:from]!='Lightbox'
            render :update do |page|
              page << "Lightbox.show('/account/login')"
            end
          end
        }
      end
    end
  end
 
  #登出
  #TODO:退出时 返回到推出前所在的页面，不是退到Index页面
  def logout
    cookies.delete(:auto_login_user_id)
    set_user_session()
    redirect_to( accounts_path() )
  end
  #begin 一些设置功能
  #忘记密码
  def forget_password
    @page_title ="取回密码"
    if request.post?
      user= User.real_users.find_by_email(params[:email])
      if user
        token=Token.new_recovery(user)
        if token.save
          MailerServer.deliver_forget_password(token)
          params[:email] = nil
          flash.now[:success] = "重设密码链接，已发送到#{user.email}邮箱！"
        end
      else
        flash.now[:notice] = "#{params[:email]}邮件地址未注册！"
      end
    end
  end
  #重设密码
  def reset_password
    @page_title ="设置新密码"
    @token=Token.new
    @token.user = User.real_users.first
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
      flash[:error] = "重设密码链接已经失效,请重新获取！"
      redirect_to(forget_password_account_path())
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

  #设置用户的状态
  def set_user_state
    current_user.update_attribute("state", params[:state] || User::STATE_TYPES.keys[0].to_s())
    new_state = params[:state] || User::STATE_TYPES.keys[0].to_s
    new_state_content =User::STATE_TYPES[new_state.to_sym]
    LogItem.create(:owner=>current_user,:log_type=>"state_change",:changes=>new_state,:operation=>"create")
    render :update do |page|
      page["user_img_button"].title =  "#{current_user.name} 状态 #{new_state_content}"
      page.select(".current_user_state").each do |item|
        page << "value.title = '#{new_state_content}';"
        page << "value.className ='user_state_at_icon user_state_#{new_state} current_user_state';"
      end
    end
  end

  def search
    case params[:type]
    when "group"
      redirect_to search_groups_path(:search=>params[:search])
    when "company"
      redirect_to search_companies_path(:search=>params[:search])
    when "need_job"
      redirect_to search_need_jobs_path(:search=>params[:search])
    else
      redirect_to search_jobs_path(:search=>params[:search])
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
    respond_to do |format|
      format.js{
        render :update do |page|
          if current_user.add_attention(target_object)
            page[dom_id(target_object,"operation")].replace_html render(:partial=>"#{target.base_class.to_s.pluralize.downcase}/operation",:object=>target_object)
            page[dom_id(target_object,"operation")].visual_effect(:highlight)
          else
            flash.now[:error] = current_user.errors.full_messages.to_s
            page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
          end
        end
      }
    end
  end
  #取消关注
  def destroy_attention
    target = params[:target_type].to_s.camelize.constantize
    target_object = target.find(params[:target_id])
    respond_to do |format|
      format.js{
        render :update do |page|
          if current_user.remove_attention(target_object)
            page[dom_id(target_object,"operation")].replace_html render(:partial=>"#{target.base_class.to_s.pluralize.downcase}/operation",:object=>target_object)
            page[dom_id(target_object,"operation")].visual_effect(:highlight)
          else
            flash.now[:error] = current_user.errors.full_messages.to_s
            page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
          end
        end
      }
    end
  end
 

  def set_signature
    unless [:post, :put].include?(request.method) then
      return render(:text => 'Method not allowed', :status => 405)
    end
    current_user.set_signature(params[:value])
    render :text => CGI::escapeHTML(current_user.signature)
  end

  #给同事的评价
  def judged_colleagues
    @page_title ="给同事的评价"
    @user = current_user
    if params[:pass_id]
      @pass = Pass.find(params[:pass_id])
      @judged= @pass.judged_infos.paginate :page => params[:page]
    else
      @judged= @user.judged_infos.paginate :page => params[:page]
    end
  end
  
  #未评价的同事
  def unjudge_colleagues
    @page_title ="未评价的同事信息"
    @user = current_user
    if params[:pass_id]
      @pass = Pass.find(params[:pass_id])
      @unjudge_colleagues = @pass.not_judge_them_colleague_users.paginate  :page => params[:page]
    else
      @unjudge_colleagues =  @user.not_judge_them_colleague_users.paginate  :page => params[:page]
    end
  end
  
  #给公司的评价
  def judged_company
    @page_title ="给公司的评价信息"
    @user = current_user
    @judged_companies = @user.judged_companies.paginate :page => params[:page]
  end
  
  def unjudge_company
    @page_title ="未评价的公司信息"
    @user = current_user
    @unjudge_companies = @user.unjudge_companies.paginate :page => params[:page]
  end

  def published_jobs
    @user = current_user
    @page_title = '我发布的职位'
    @jobs = @user.published_jobs.paginate :page=>params[:page]
  end
  
  def published_job_applicants
    @user = current_user
    @page_title = '发布的职位申请记录'
    @applicants = @user.published_job_applicants.paginate :page=>params[:page]
  end

  def job_applicants
    @user = current_user
    @page_title = '我的职位申请记录'
    @applicants = @user.job_applicants.paginate :page=>params[:page]
  end

  def need_jobs
    @page_title = '我的求职列表'
    @need_jobs = current_user.need_jobs.paginate :page=>params[:page]
  end
  

  def add_job
    @page_title = '新建招聘职位'
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
    set_user_session()
    if code==0
      set_user_session(user)
      if auto_login
        cookies[:auto_login_user_id]= {:value=>user.id, :expires => 1.month.from_now}
      end
      "成功"
    else
      #返回失败的原因
      if (code==-1)
        email+"邮件不存在,<a href=#{new_account_path(:email=>email)}>那现在注册吧！</a>"
      else
        "密码错误,<a href=#{forget_password_account_path(:email=>email)}>取回密码！</a>"
      end
    end
  end
end
