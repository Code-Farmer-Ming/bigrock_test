class BroadcastsController < ApplicationController
  before_filter :check_login?
    
  # GET /broadcasts
  # GET /broadcasts.xml
  def index
    @broadcasts = current_user.user_broadcasts.paginate :page => params[:page]

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @broadcasts }
    end
  end

  # GET /broadcasts/1
  # GET /broadcasts/1.xml
  def show
    @broadcast = Broadcast.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @broadcast }
    end
  end

  # GET /broadcasts/new
  # GET /broadcasts/new.xml
  def new
    @broadcast = Broadcast.new

    respond_to do |format|
      format.html # new.html.erb
      format.js # new.html.erb
      format.xml  { render :xml => @broadcast }
    end
  end

  # GET /broadcasts/1/edit
  def edit
    @broadcast = Broadcast.find(params[:id])
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
        #自己不再收到 廣播
        current_user.send_broadcast(@broadcast,[current_user], true)
        #把广播 发送到 关注当前用户所有的人
        current_user.send_broadcast(@broadcast,current_user.follow_me_users)
        
        flash.now[:success] = "成功传播给#{current_user.follow_me_users.size}个朋友！"
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

  # PUT /broadcasts/1
  # PUT /broadcasts/1.xml
  def update
    @broadcast = Broadcast.find(params[:id])

    respond_to do |format|
      if @broadcast.update_attributes(params[:broadcast])
        flash[:notice] = 'Broadcast was successfully updated.'
        format.html { redirect_to(@broadcast) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @broadcast.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /broadcasts/1
  # DELETE /broadcasts/1.xml
  def destroy
    @broadcast = Broadcast.find(params[:id])
    @broadcast.destroy

    respond_to do |format|
      format.html { redirect_to(broadcasts_url) }
      format.xml  { head :ok }
    end
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
