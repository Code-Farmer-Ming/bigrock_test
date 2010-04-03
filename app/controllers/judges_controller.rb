#TODO：操作的安全性需要考虑
class JudgesController < ApplicationController
  before_filter :check_login?
  def new
    @judge= Judge.new
    @judge.anonymous=false
    respond_to do |format|
      format.html # new.html.erb
      format.js
      format.xml  { render :xml => @judge }
    end
  end
  #TODO:   @pass=Pass.find(params[:pass_id])有一定的危险 修改成 @user.passes.find(X)和 current_user 同事的判断
  def create
    @user = User.real_users.find(params[:user_id])
    @pass= @user.passes.find(params[:pass_id])

    @judge= Judge.new(params[:judge])
    @judge.user =  @user
    @judge.judger = current_user
    if  !@pass.yokemate?(current_user) || @pass.judges.exists?(["judger_id=?",current_user.id]) || !(@pass.judges << @judge)
      #提示错误
      flash.now[:error] = "添加失败,关闭后再重试！"
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
    @judge = Judge.find(params[:id])
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
