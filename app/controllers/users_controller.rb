class UsersController < ApplicationController
  before_filter :check_login?,:except=>[:show]
  before_filter :find_user,:only=>[:show,:yokemate_list,:logs,:friends,:groups]
  def show
    if current_user
      @page_title ="#{@user.name}"
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @user }
      end
    else
      redirect_to user_resumes_path(@user)
    end
  end

  def yokemate_list
    @page_title ="#{@user.name} 同事信息列表"
    if !params[:pass_id]
      @yokemates=@user.current_resume.yokemates.paginate :page => params[:page]
    else
      @pass =@user.current_resume.passes.find(params[:pass_id])
      @yokemates =@pass.yokemates.paginate :page => params[:page]
    end
  end

  #用户的活动日志记录
  def logs
    @page_title ="#{@user.name} 动态记录"
    if params[:type]=="" || params[:type]==nil || params[:type]=="all"
      @log_items = @user.log_items.paginate :page => params[:page]
    else
      @log_items = @user.log_items.paginate_by_log_type params[:type], :page => params[:page]
    end
  end

  def friends
    @page_title ="#{@user.name} 好友列表"

    case params[:type]
      #    when "my_follow"
      #      @friends_user =@user.my_follow_users.paginate :joins=>" join resumes on resumes.user_id=users.id",
      #        :conditions=>["resumes.user_name like ?",'%'+ (params[:search] || '') +'%'], :page => params[:page]
      #    when "follow_me"
      #      @friends_user =@user.follow_me_users.paginate  :joins=>" join resumes on resumes.user_id=users.id",
      #        :conditions=>["resumes.user_name like ?",'%'+ (params[:search] || '') +'%'], :page => params[:page]
    when "work_for_company"
      @friends_user = @user.pass_companies.paginate :conditions=>["name like ?",'%'+ (params[:search] || '') +'%'], :page => params[:page]
    when "follow_company"
      @friends_user =@user.my_follow_companies.paginate :conditions=>["name like ?",'%'+ (params[:search] || '') +'%'], :page => params[:page]
    else
      @friends_user = @user.friend_users.paginate  :joins=>" join resumes on resumes.user_id=users.id",
        :conditions=>["resumes.user_name like ?",'%'+ (params[:search] || '') +'%'], :page => params[:page]
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @friends_user }
    end
  end
  
  def groups
    @page_title ="#{@user.name} 参加的小组"
    if current_user?(@user)
      case params[:type]
      when "manage"
        @groups =@user.manage_groups.paginate :conditions=>"name like '%#{params[:search]}%'", :page => params[:page]
      when "create"
        @groups =@user.create_groups.paginate  :conditions=>"name like '%#{params[:search]}%'",:page => params[:page]
      when "hidden"
        @groups =@user.hidden_groups.paginate  :conditions=>"name like '%#{params[:search]}%'",:page => params[:page]
      else
        @groups =@user.all_groups.paginate  :conditions=>"name like '%#{params[:search]}%'", :page => params[:page]
      end
    else
      @groups =@user.groups.paginate  :conditions=>"name like '%#{params[:search]}%'", :page => params[:page]
    end
  end

  protected

  def find_user
    @user = User.real_users.find(params[:id])
  end
end
