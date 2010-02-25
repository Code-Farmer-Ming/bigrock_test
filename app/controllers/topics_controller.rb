class TopicsController < ApplicationController
  before_filter :check_login?,:except=>[:show,:index]
  # GET /topics
  # GET /topics.xml
  def index
    if params[:company_id]
      @owner = Company.find(params[:company_id])
    else
      @owner = Group.find(params[:group_id])
    end
    @topics = @owner.topics.paginate :page => params[:page]
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @topics }
    end
  end

  # GET /topics/1
  # GET /topics/1.xml
  def show
    @topic = Topic.find(params[:id])
    @can_reply = true
    if @topic.owner_type=="Group"#group topics
      @can_reply =  @topic.owner.is_member?(current_user)
    end
    @comments = @topic.comments.paginate :page => params[:page]
    @is_owner = is_owner?(@topic)
    @is_manager  = is_manager?(@topic)
    @page_title= " 话题 " + @topic.title
    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @topic }
    end
  end

  # GET /topics/new
  # GET /topics/new.xml
  #TODO: 其他 group等的判断
  def new
    @topic = Topic.new
    if params[:company_id] #company
      @owner = Company.find(params[:company_id])
    else
      @owner = Group.find(params[:group_id])
      if !@owner.is_member?(current_user)
        flash[:notice] = "你无权限发表内容！"
        redirect_to @owner
      end
    end
  end

  # GET /topics/1/edit
  def edit
    @topic = Topic.find(params[:id])
    if !is_manager?(@topic) && !is_owner?(@topic)
      flash[:error] = "操作错误"
      redirect_to :action=>:show,:id=>@topic
    end
  end

  # POST /topics
  # POST /topics.xml
  def create
    @topic = Topic.new(params[:topic])
    @topic.last_comment_datetime = Time.now
    if params[:company_id] #company
      @owner = Company.find(params[:company_id])
      @topic.owner = @owner
      @topic.author = current_user.get_account(params[:alias])
    else #group
      @owner = Group.find(params[:group_id])
      @topic.owner = @owner
      @topic.author = @owner.all_members.first(:conditions=>["users.id in (?)", current_user.ids])
      if !@owner.is_member?(current_user)
        flash[:notice] = "你无权限发表内容！"
        redirect_to @owner
        return
      end
    end
    respond_to do |format|
      if @topic.save
        format.html { redirect_to([@topic.owner,@topic]) }
        format.xml  { render :xml => @topic, :status => :created, :location => @topic }
      else
        flash.now[:error] = '发生错误'+$!
        format.html {
          render :action => "new" }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /topics/1
  # PUT /topics/1.xml
  def update
    @topic = Topic.find(params[:id])
    if !is_manager?(@topic) && !is_owner?(@topic)
      flash[:error] = "操作错误"
      redirect_to :action=>:show,:id=>@topic
      return
    end
    respond_to do |format|
      if @topic.update_attributes(params[:topic])
        flash[:notice] = '更新成功.'
        format.html { redirect_to([@topic.owner,@topic]) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @topic.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /topics/1
  # DELETE /topics/1.xml
  def destroy
    @topic = Topic.find(params[:id])
    owner = @topic.owner
    @is_manager =is_manager?(@topic)
    respond_to do |format|
      if @is_manager || is_owner?(@topic)
        if @topic.destroy
          format.html { flash[:success]="删除成功"
            redirect_to(owner) }
          format.xml  { head :ok }
        else
          format.html {
            flash[:error]="删除错误 "+$!
            redirect_to([owner,@topic]) }
          format.xml  { head :ok }
        end
      else
        format.html {
          flash[:error]="删除错误"
          redirect_to([owner,@topic])
        }
        format.xml  { head :fails }
      end
    end
  end
  #顶 新闻
  def up
    @topic = Topic.find(params[:id])
    @topic.votes << Vote.new(:value=>1,:user=>current_user)
    @topic.up += 1
    @topic.save
    render :partial => "comm_partial/update_up_down_panel",:object=>@topic
  end
  #踩 新闻
  def down
    @topic = Topic.find(params[:id])
    @topic.down += 1
    @topic.votes << Vote.new(:value=>-1,:user=>current_user)
    @topic.save
    render :partial => "comm_partial/update_up_down_panel",:object=>@topic
  end
  #置顶 话题
  def set_top_level
    @topic = Topic.find(params[:id])
    @is_manager =is_manager?(@topic)
    if @is_manager
      @topic.update_attribute("top_level", true) unless @topic.top_level
      flash.now[:success] = "置顶成功！"
    else
      flash.now[:error] = "设置错误"
    end
    render :update do |page|
      page["topic_operation"].replace_html render(:partial=>"topics/operation")
      page["topic_operation"].visual_effect :highlight
      page["flash_msg"].replace_html(render(:partial=>"comm_partial/flash_msg"))
    end    
  end
  #取消置顶
  def cancel_top_level
    @topic = Topic.find(params[:id])
    @is_manager =is_manager?(@topic)
    if @is_manager
      @topic.update_attribute("top_level", false) unless !@topic.top_level
      flash.now[:success] = "取消成功！"
    else
      flash.now[:error] = "设置错误"
    end
    render :update do |page|
      page["topic_operation"].replace_html render(:partial=>"topics/operation")
      page["topic_operation"].visual_effect :highlight
      page["flash_msg"].replace_html(render(:partial=>"comm_partial/flash_msg"))
    end    
  end
  
  def search
    search_str = "%#{params[:search]}%"
    @topics = nil
    if params[:group_id]
      @owner = Group.find(params[:group_id])
      @topics = @owner.topics.paginate  :conditions=>["title like ? or content like ?",search_str,search_str], :page => params[:page]
    elsif  params[:company_id]
      @owner = Company.find(params[:company_id])
      @topics = @owner.topics.paginate  :conditions=>["title like ? or content like ?",search_str,search_str], :page => params[:page]
    end
  end
  
  private
  #检查当前用户的权限
  def is_manager?(topic)
    if topic.owner_type=="Group"#group topics
      topic.owner.is_manager_member?(current_user)
    else #company topics
      topic.owner.current_employee?(current_user)  #TODO:current_employee 需要做信用检查
    end
  end
  #当前用户是否 拥有者
  def is_owner?(topic)
    current_user?(topic.author)
  end
end
