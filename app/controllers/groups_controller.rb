class GroupsController < ApplicationController
  before_filter :check_login?,:except=>[:index,:show,:show_by_tag]
  # GET /groups
  # GET /groups.xml
  def index
    #    @groups = Group.all
    @page_title =  "小组首页"
    @hot_tags= Group.all_tags(:limit=>20)
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @groups }
    end
  end

  # GET /groups/1
  # GET /groups/1.xml
  def show
    @group = Group.find(params[:id])
    @page_title =  @group.name + " 小组"
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @group }
    end
  end

  # GET /groups/new
  # GET /groups/new.xml
  def new
    @group = Group.new
    @page_title =  "创建小组"
    if current_user.manage_groups.size>=4
      flash[:notice] = "你已经管理4个小组了，太多了吧"
      redirect_to  groups_path()
    end
  end

  # GET /groups/1/edit
  def edit
    @group = Group.find(params[:id])
    @page_title = @group.name + " 编辑"
    if !@group.is_manager_member?(current_user)
      flash[:notice] = "操作错误！"
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
        @group.roots << @group.create_user 
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
    @group = Group.find(params[:id])
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
    @group = Group.find(params[:id])
    @group.destroy

    respond_to do |format|
      format.html { redirect_to(groups_url) }
      format.xml  { head :ok }
    end
  end
  #加入小组
  def join
    group = Group.find_by_id(params[:id])
    #加入方式为开放
    if group && group.join_type==Group::JOIN_TYPES[0][1] 
      if  !group.is_member?(current_user)
        group.all_members << current_user.get_account(params[:alias])
      end
      render :update do |page|
        page["group_operation"].replace_html render(:partial=>"groups/operation",:object=> group)
        page["group_operation"].visual_effect :highlight
      end
    else
      flash.now[:error] = "加入小组出错!#{$!}"
      render :update do |page|
        page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
      end
    end
  end
  #退出小组
  def quit
    group = Group.find_by_id(params[:id])
    
    if (group.roots.size==1 && group.is_root?(current_user))
      flash.now[:notice] = "现在不能退出小组,小组必须有一个组长，在指定其他人为组长后才能退出。"
      render :update do |page|
        page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
      end
    else
      if Member.destroy_all(["user_id=? and group_id=?",current_user,group])
        render :update do |page|
          page["group_operation"].replace_html render(:partial=>"groups/operation",:object=> group)
          page["group_operation"].visual_effect :highlight
        end
      else
        flash.now[:error] = "退出小组出错!"
        render :update do |page|
          page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
        end
      end
    end
  end
  
  #邀请好友加入
  def invite_join
    @group = Group.find_by_id(params[:id])
    @invite =  JoinGroupInvite.new(params[:join_group_invite])
    @friends = current_user.friends_user.paginate :conditions=>"users.nick_name like '%#{params[:search]}%'", :page => params[:page], :per_page=>1
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
  #根据 tag 显示相关 公司的信息
  def show_by_tag
    @tag = Tag.find(params[:tag_id])
    #    taggable_ids = @tag.taggings.all(:conditions=>["taggable_type=?",Company.to_s],:limit=>10,:order=>"user_tags_count desc").map(&:taggable_id)
    @similar_taggings = Group.find_related_tags(@tag.name,:limit=>10) #Tagging.find(:all,:conditions=>["taggable_id in (?) and tag_id<>?",taggable_ids,@tag.id],:limit=>10,:order=>"user_tags_count desc")
    @groups = @tag.taggables.paginate_by_taggable_type "Group", :page => params[:page],:order=>params[:order]
  end
    #所有关于公司的 标签
  def all_tags
    @tags =  Group.all_tags.paginate :page => params[:page]
  end
 
  def auto_complete_for_tag
    @items =  Tag.find(:all,
      :conditions =>" lower(name) like '%#{params[:group][:tag_list].downcase}%' ",
      :select=>"distinct name" )
    render :inline => "<%= auto_complete_result @items, 'name', '#{params[:group][:tag_list]}' %>"
  end
end
