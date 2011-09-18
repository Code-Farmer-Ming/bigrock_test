class UsersController < ApplicationController
  before_filter :check_login?,:except=>[:show,:info_render]
  before_filter :find_user,:only=>[:show,:colleague_list,:logs,:following,:groups,:info_render]
  def show
    #    if current_user
    @logs = @user.log_items.paginate :page => params[:page]
    @page_title ="#{@user.name}"
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @user }
    end
    #    else
    #      redirect_to user_path(@user)
    #    end
  end

  def colleague_list
    @page_title ="#{@user.name} 同事信息列表"
    if !params[:pass_id]
      @colleeagus=@user.colleague_users.paginate :page => params[:page]
    else
      @pass =@user.passes.find(params[:pass_id])
      @colleeagus =@pass.colleague_users.paginate :page => params[:page]
    end
  end

  #用户的活动日志记录
  def logs
    @logs = @user.log_items.paginate :page => params[:page]
  end
  #关注的用户和公司
  def following
    @page_title ="#{@user.name} 好友列表"

    case params[:type].to_s
    when "work_for_company"
      @following_objs = @user.pass_companies.paginate :conditions=>["name like ?",'%'+ (params[:search] || '') +'%'], :page => params[:page]
    when "company"
      @following_objs =@user.my_follow_companies.paginate :conditions=>["name like ?",'%'+ (params[:search] || '') +'%'], :page => params[:page]
    when "follow_me"
      @following_objs =@user.follow_me_users.paginate :conditions=>["nick_name like ?",'%'+ (params[:search] || '') +'%'], :page => params[:page]
    else
      @following_objs =@user.my_follow_users.paginate :conditions=>["nick_name like ?",'%'+ (params[:search] || '') +'%'], :page => params[:page]
    end

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @following_objs }
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

  def info_render
    if  @user.setting.can_see_resume(current_user)
      render :partial=>"users/body_render",:object=>@user
    else
      render :text=>"<div class='text_center'> <h2>详细资料已经设置为不公开</h2></div>"
    end
  end

  protected

  def find_user
    @user = User.real_users.find(params[:id])
  end
end
