class GroupsController < ApplicationController
  include ActionView::Helpers::TextHelper
  before_filter :check_login?,:except=>[:index,:show,:search]
  before_filter :find_group,:only=>[:show,:edit,:update,:destroy,:quit,:invite_join]
  # GET /groups
  # GET /groups.xml
  def index
    #    @groups = Group.all
    @page_title =  "小组首页"
    @page_description="小组首页,显示最新创建的小组,小组最新发表的话题"
    @hot_tags= Group.all_tags(:limit=>20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    @page_title =  @group.name + " 小组"
    @page_description =  truncate(@group.description,:length=>100)
    @page_keywords=@group.tag_list
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @page_title =  "创建小组"
    if !Group.can_create?(current_user)
      flash[:notice] = "你已经管理多个小组了，精力好像不够吧。"
      redirect_to  groups_path()
    else
      @group = Group.new
    end
  end

  # GET /groups/1/edit
  def edit
    @page_title = @group.name + " 编辑"
    if !@group.is_manager_member?(current_user)
      flash[:notice] = @group.errors.full_messages.to_s
      redirect_to @group
    end
  end

  # POST /groups
  # POST /groups.xml
  def create
    @group = Group.new(params[:group])
    if params[:uploaded_file_id] && params[:uploaded_file_id]!=""
      @group.icon = GroupIcon.find(params[:uploaded_file_id])
    end
    @group.create_user =  current_user.get_account(params[:alias])
    respond_to do |format|
      if @group.save
        format.html { redirect_to(@group) }
        format.xml  { render :xml => @group, :status => :created, :location => @group }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @group.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /groups/1
  # PUT /groups/1.xml
  def update
    if params[:uploaded_file_id] && params[:uploaded_file_id]!=""
      @group.icon = GroupIcon.find(params[:uploaded_file_id])
    end
    #    if !@group.is_manager_member?(current_user)
    #      flash[:notice] = "操作错误！"
    #      redirect_to @group
    #    else
    if @group.update_attributes(params[:group])
      flash[:success] = '信息修改成功.'
      redirect_to(@group)
    else
      flash[:error] = '修改失败.'
      render :action => "edit"
    end
    #    end
 
  end

  # DELETE /groups/1
  # DELETE /groups/1.xml
  def destroy
    respond_to do |format|
      if @group.root_destroy(current_user)
        format.html { redirect_to(groups_url) }
      else
        flash.now[:error] = @group.errors.full_messages.to_s
        format.html { redirect_to :show}
      end
    end
  end
  #加入小组
  def join
    group = Group.find(params[:id])
    #加入方式为开放
    if group.is_open_join?
      group.add_to_member(current_user.get_account(params[:alias]))
      render :update do |page|
        page[dom_id(group,"operation")].replace_html render(:partial=>"groups/operation_content",:object=> group)
        page.select(".member_count").each do |item|
          page.replace_html item,group.members.size
        end
        page[dom_id(group,"operation")].visual_effect :highlight
      end
    else
      flash.now[:error] = "加入小组出错!"
      render :update do |page|
        page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
      end
    end
  end
  #退出小组
  def quit
    if @group.remove_member(current_user)
      render :update do |page|
        page[dom_id(@group,"operation")].replace_html render(:partial=>"groups/operation_content",:object=> @group)
        page[dom_id(@group,"operation")].visual_effect :highlight
        page.select(".member_count").each do |item|
          page.replace_html item,@group.members.size
        end
      end
    else
      flash.now[:error] = @group.errors.full_messages.to_s
      render :update do |page|
        page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
      end
    end
 
  end
  
  #邀请好友加入
  def invite_join
    @page_title = " 邀请好友加入 " + @group.name
    @invite =  JoinGroupInvite.new(params[:join_group_invite])
    @friends = current_user.my_follow_users.paginate :joins=>" join resumes on resumes.user_id=users.id", :conditions=>["resumes.user_name like ?",'%'+ (params[:search] || '') +'%'], :page => params[:page]
    if request.post?
      if (params[:invite_user])
        params[:invite_user].each do |friend|
          invite_join =  JoinGroupInvite.new(params[:join_group_invite])
          invite_join.respondent_id = friend
          invite_join.applicant = @group
          invite_join.memo = "好友 <a href='#{user_path(current_user)}'> #{current_user.name}</a> 邀请你加入 <a href='#{group_path(@group)}'>#{@group.name}</a> <br />"+invite_join.memo
          invite_join.save
        end
        flash.now[:success] = "已经发出邀请！"
      else
        flash.now[:notice] = "请选择要邀请的好友！"
      end
    end
  end
   
  def auto_complete_for_tag
    @items =  Tag.find(:all,
      :conditions =>" lower(name) like '%#{params[:group][:tag_list].downcase}%' ",
      :select=>"distinct name" )
    render :inline => "<%= auto_complete_result @items, 'name', '#{params[:group][:tag_list]}' %>"
  end
  
  def search
    search_str = "%#{params[:search]}%"
    @page_title = " 小组信息搜索 "
    @groups = Group.paginate(:conditions=>["name like ? or description like ?",search_str,search_str] ,:page => params[:page])
  end

  protected

  def find_group
    @group = Group.find(params[:id])
  end
end
