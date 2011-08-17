class BroadcastsController < ApplicationController
  before_filter :check_login?
    
  # GET /broadcasts
  # GET /broadcasts.xml
  def index
    @page_title="转发列表"
    @broadcasts = current_user.user_broadcasts.paginate :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @broadcasts }
    end
  end
 

  # GET /broadcasts/new
  # GET /broadcasts/new.xml
  def new
    @broadcast = Broadcast.new
    @find_broadcastable = find_broadcastable
    respond_to do |format|
      format.html # new.html.erb
      format.js # new.html.erb
      format.xml  { render :xml => @broadcast }
    end
  end
 

  # POST /broadcasts
  # POST /broadcasts.xml
  def create
    @find_broadcastable = find_broadcastable
    @broadcast = @find_broadcastable.broadcasts.build(params[:broadcast]) 
    respond_to do |format|
      if current_user.broadcasts <<@broadcast
        #把当前 广播对象 当前公司的同事过滤
        if (@find_broadcastable.class.to_s=="NeedJob")
          current_user.send_broadcast(@broadcast,@find_broadcastable.poster.current_company_colleages,true)
        end
        #创建者也过滤
        current_user.send_broadcast(@broadcast,[@find_broadcastable.poster], true)
        if !current_user?(@find_broadcastable.poster)
          Msg.new_system_msg(:title=>"[#{current_user.name}]帮你转发了一条信息",
            :content=>"<a href=' #{ user_path(current_user) }' >#{current_user.name}</a>把您发布的<a href='#{url_for(@find_broadcastable)}'>[#{@find_broadcastable.title}]</a>转发给了TA的朋友").
            send_to(@find_broadcastable.poster)
        end

        #把广播 发送到 所有关注我的用户
        sucess_broadcast_count = current_user.send_to_flow_me_user_broadcast(@broadcast)

        if sucess_broadcast_count>0
          flash.now[:success] = "成功转发给了#{sucess_broadcast_count}个关注您的人！"
        else
          flash.now[:success] = "成功转发给了关注您的人！"
        end
        format.js  {}
        format.html { redirect_to(@broadcast) }
        format.xml  { render :xml => @broadcast, :status => :created, :location => @broadcast }
      else
        format.js  {}
        format.html { render :action => "new" }
        format.xml  { render :xml => @broadcast.errors, :status => :unprocessable_entity }
      end
    end
  end

  #再次转发
  def  redo
    #把广播 发送到 关注当前用户所有的人
    @user_broadcast = current_user.user_broadcasts.find(params[:id])
    sucess_broadcast_count = current_user.send_broadcast(@user_broadcast.broadcast,current_user.follow_me_users)
    @user_broadcast.read()

    Msg.new_system_msg(:title=>"[#{current_user.name}]帮你转发了一条信息",
      :content=>"<a href=' #{ user_path(current_user) }' >#{current_user.name}</a>再次把您发布的[#{@user_broadcast.broadcast.broadcastable.title}]转发给了TA的朋友").
      send_to(@find_broadcastable.poster)
 
    if sucess_broadcast_count>0
      flash.now[:success] = "成功转发给了#{sucess_broadcast_count}个关注您的人！"
    else
      flash.now[:success] = "成功转发给了关注您的人！"
    end
  end

  #忽略转发
  def ignore
    @user_broadcast = current_user.user_broadcasts.find(params[:id]) 
    @user_broadcast.read()
  end
 

  private
  
  def find_broadcastable
    params.each do |name, value|
      if name =~ /(.+)_id$/
        return $1.classify.constantize.find(value)
      end
    end
    nil
  end
end
