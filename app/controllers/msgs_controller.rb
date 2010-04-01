class MsgsController < ApplicationController
  before_filter :check_login?
  before_filter :find_msg,:only=>[:show,:destroy,:msg_response]
  
  def show
    @page_title = @msg.title if @msg
    if @msg
      @msg.read_msg(current_user)
      @msg_response = MsgResponse.new()
    else
      redirect_to account_msgs_path()
    end
  end

  def index
    case params[:type] 
    when "send" then
      @msgs = current_user.send_msgs.paginate :page => params[:page]
    when "recieve" then
      @msgs =  current_user.receive_msgs.paginate :page => params[:page]
    else
      @msgs =  current_user.new_msgs.paginate :page => params[:page]
    end
    @page_title =  "#{current_user.name} 消息"
  end
  
  def new
    @page_title = "写新消息"
    @msg= Msg.new
    @msg.sendees = ''
    if params[:write_to]  
      @write_to= User.find(:first,:conditions=>["id=? or salt=?",params[:write_to],params[:write_to]])
    
      #      if @write_to
      #        @msg.sendees="#{@write_to.salt}"
      #      end
    end
  end

  def create
    @page_title = "发送消息"
    @msg= Msg.new(params[:msg])
    @msg.sender =  current_user.get_account(params[:alias])
    respond_to do |format|
      if Msg.save_all(@msg)
        format.html {
          flash[:success] = "消息发送成功！"
          redirect_to  :action=>"new" }
      else
        format.html {
          render  "new"  }
      end
   
    end
  end

  def destroy
    @msg.stop_or_destroy(current_user)
    respond_to do |format|
      format.html { redirect_to(account_msgs_path(:type=>params[:type])) }
      format.xml  { head :ok }
    end
  end

  #查找用户
  def auto_complete_for_msg_sendees
    #    if (params[:company][:name]!="")
    ActiveRecord::Base.include_root_in_json = false

    @items =  current_user.friends_user.find(:all,
      :conditions =>"(lower(resumes.user_name) like lower('%#{params[:search]}%') )and resumes.is_current=#{true}",
      :joins =>"join resumes on resumes.user_id=users.id ",:limit=>params[:max],:select=>"users.id   value,resumes.user_name  text" )
    render :json => @items.to_json()
  end
  
  #回复
  def msg_response
    @msg_response = msg_response.new(params[:response])
    @msg_response.sender_id = current_user.ids.include?(@msg.sender_id) ? @msg.sender_id : @msg.sendee_id
    respond_to do |format|
      if @msg.response(@msg_response)
        format.js { }
      else
        flash.now[:notice] =   "发送失败！" +@msg_response.errors.full_messages 
      end
    end
  end

  protected

  def find_msg
    @msg = current_user.all_msgs.find(params[:id])
  end

end
