class MsgsController < ApplicationController
  before_filter :check_login?
  
  def show
    @msg = current_user.all_msgs.find(params[:id])
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
  end
  
  def new
    @page_title = "写新消息"
    @msg= Msg.new
    if params[:write_to]
      write_to= User.find(params[:write_to])
      @msg.sendees="#{ write_to.name}(#{write_to.id});"
    end
  end

  def create
    @msg= Msg.new(params[:msg])
    @msg.sender =  current_user.get_account(params[:alias])
    respond_to do |format|
      if Msg.save_all(@msg)
        format.html {
          flash[:success] = "发送成功！"
          redirect_to  :action=>"new" }
      else
        format.html {
          render  "new"  }
      end
   
    end
  end

  def destroy
    msg = Msg.find(params[:id])
    msg.stop_or_destroy(current_user)
    respond_to do |format|
      format.html { redirect_to(account_msgs_path(:type=>params[:type])) }
      format.xml  { head :ok }
    end
  end

  #查找用户
  def auto_complete_for_msg_sendees
    #    if (params[:company][:name]!="")
    @items =  current_user.friends_user.find(:all,
      :conditions =>"(lower(resumes.user_name) like lower('%#{params[:msg][:sendees]}%') )and resumes.is_current=#{true}",
      :joins =>"join resumes on resumes.user_id=users.id " )
    render :inline => "<ul><%= render :partial=>'msgs/user_list',:collection=>@items, :locals =>{:phrase=> '#{params[:msg][:sendees]}'} %></ul>"
  end
  
  #回复
  def msg_response
    @msg = current_user.all_msgs.find(params[:id])
    @msg_response = MsgResponse.new(params[:response])
    if @msg_response.content.nil? || @msg_response.content.blank? || !@msg.can_response?
      flash.now[:notice] = "发送失败！"
      return
    end
    @msg_response.sender_id = current_user.ids.include?(@msg.sender_id) ? @msg.sender_id : @msg.sendee_id
    @msg_response.msg = @msg
    respond_to do |format|
      if @msg_response.save
        format.js { }
      end
    end
  end

end
