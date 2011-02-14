#TODO：操作的安全性需要考虑
class JudgesController < ApplicationController
  before_filter :check_login?
  def new
    @judge= Judge.new
    @judge.anonymous=false
    @judge.user = User.real_users.find(params[:user_id])
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.xml  { render :xml => @judge }
    end
  end
  #TODO: 
  def create
    colleague =  current_user.them_colleagues.find_by_colleague_id(params[:user_id])
    @judge= Judge.new(params[:judge])
    current_user.tag_something(colleague.colleague_user, params[:my_tags])
    if  !colleague.judge_colleague(@judge) #提示错误
      flash.now[:error] = @judge.errors.full_messages.to_s()
      render :update do |page|
        page["lightbox_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
      end
    end
  end
  
  def edit
    @judge = current_user.judged.find(params[:id])
    respond_to do |format|
      format.js {}
      format.html # new.html.erb
    end
  end
  
  def update
    @judge = current_user.judged.find(params[:id])
    current_user.tag_something(@judge.user, params[:my_tags])
    respond_to do |format|
      if @judge.update_attributes(params[:judge])
        format.xml  { head :ok }
        format.js {}
      else
        format.js {}
        format.html { render :action => "edit" }
        format.xml  { render :xml => @judge.errors, :status => :unprocessable_entity }
      end
    end
  end
 
  def destroy
    @judge =current_user.judged.find(params[:id])
    respond_to do |format|
      if @judge.destroy
        format.xml  { head :ok }
        format.js {}
      else
        format.html { render :action => "destroy" }
        format.xml  { render :xml => @judge.errors, :status => :unprocessable_entity }
      end
    end
  end

  def index
    @user = User.real_users.find(params[:user_id])
    @page_title ="#{@user.name} 的评价信息"
    if !params[:pass_id]
      @judges= @user.judges.paginate :page => params[:page]
    else
      @pass = Pass.find(params[:pass_id])
      @judges= @pass.judges.paginate :page => params[:page]
    end
  end

end
