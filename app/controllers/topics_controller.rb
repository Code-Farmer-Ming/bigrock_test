class TopicsController < ApplicationController
  before_filter :check_login?,:except=>[:show,:index,:search]
  before_filter :find_topic,:only=>[:show,:edit,:update,:destroy,:up,:down,:set_top_level,:cancel_top_level]
  # GET /topics
  # GET /topics.xml
  def index
    search_str = "%#{params[:search]}%"
    if params[:company_id]
      @owner = Company.find(params[:company_id])
    else
      @owner = Group.find(params[:group_id])
    end
    @topics = @owner.topics.paginate :conditions=>["title like ? or content like ?",search_str,search_str],:page => params[:page]
    @page_title = "#{@owner.name} 话题"
    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @topics }
    end
  end

  # GET /topics/1
  # GET /topics/1.xml
  def show
    @topic.increase_view_count
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
 
  def new
    @page_title= "新建话题"
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
    @page_title= "编辑话题"
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
      @topic.author = current_user.get_account(params[:alias])
    else #group
      @owner = Group.find(params[:group_id])
      @topic.author = @owner.is_member?(current_user)
    end
    if !(@topic.author)
      flash[:notice] = "你无权限发表内容！"
      redirect_to @owner
      return
    end
    respond_to do |format|
      if @owner.topics << @topic
        format.html { redirect_to([@owner,@topic]) }
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
    @topic.add_vote(Vote.new(:value=>1,:user=>current_user))
    render :partial => "comm_partial/update_up_down_panel",:object=>@topic
  end
  #踩 新闻
  def down
    @topic.add_vote(Vote.new(:value=>-1,:user=>current_user))
    render :partial => "comm_partial/update_up_down_panel",:object=>@topic
  end
  #置顶 话题
  def set_top_level
    if is_manager?(@topic)
      @topic.update_attribute("top_level", true) unless @topic.top_level
      flash.now[:success] = "置顶成功！"
    else
      flash.now[:error] = "设置错误"
    end
    render :update do |page|
      page["top_level_operation"].replace_html render(:partial=>"topics/top_level_operation",:object=>@topic)
      page["topic_operation"].visual_effect :highlight
      page["flash_msg"].replace_html(render(:partial=>"comm_partial/flash_msg"))
    end    
  end
  #取消置顶
  def cancel_top_level
 
    if  is_manager?(@topic)
      @topic.update_attribute("top_level", false) unless !@topic.top_level
      flash.now[:success] = "取消成功！"
    else
      flash.now[:error] = "设置错误"
    end
    render :update do |page|
      page["top_level_operation"].replace_html render(:partial=>"topics/top_level_operation",:object=>@topic)
      page["topic_operation"].visual_effect :highlight
      page["flash_msg"].replace_html(render(:partial=>"comm_partial/flash_msg"))
    end    
  end
  
  def search
    search_str = "%#{params[:search]}%"
    @page_title= "搜索话题"
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
      #       topic.owner.higher_creditability_employees.exists?(current_user)
    end
 
  end
  #当前用户是否 拥有者
  def is_owner?(topic)
    current_user?(topic.author)
  end

  def find_topic
    @topic = Topic.find(params[:id])
  end
end
