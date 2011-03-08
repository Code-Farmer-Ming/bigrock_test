class ColleaguesController < ApplicationController
  before_filter :check_login?
  # GET /colleagues
  # GET /colleagues.xml
  def index
    @user = User.find(params[:user_id])
    @page_title ="#{@user.name} 同事信息列表"
    if params[:type]=="undetermined"
      if !params[:pass_id]
        @colleeagus=@user.undetermined_colleague_users.paginate :page => params[:page]
      else
        @pass =@user.current_resume.passes.find(params[:pass_id])
        @colleeagus =@pass.undetermined_colleague_users.paginate :page => params[:page]
      end
    else
      if !params[:pass_id]
        @colleeagus=@user.colleague_users.paginate :page => params[:page]
      else
        @pass =@user.current_resume.passes.find(params[:pass_id])
        @colleeagus =@pass.colleague_users.paginate :page => params[:page]
      end
    end
  end
  #确认
  def confirm
    @colleague = current_user.all_colleagues.find(params[:id])
    @colleague.confirm_colleague
    render :update do |page|
      page[dom_id(@colleague.colleague_user,"operation")].replace_html render(:partial=>"users/operation",:object=>@colleague.colleague_user)
      page[dom_id(@colleague.colleague_user,"operation")].visual_effect(:highlight)
    end
  end
  #取消
  def cancel
    @colleague = current_user.all_colleagues.find(params[:id])
    @colleague.not_colleague
    render :update do |page|
      page[dom_id(@colleague.colleague_user,"operation")].replace_html render(:partial=>"users/operation",:object=>@colleague.colleague_user)
      page[dom_id(@colleague.colleague_user,"operation")].visual_effect(:highlight)
    end
  end
#  # DELETE /colleagues/1
#  # DELETE /colleagues/1.xml
#  def destroy
#    @colleague = Colleague.find(params[:id])
#    @colleague.destroy
#
#    respond_to do |format|
#      format.html { redirect_to(colleagues_url) }
#      format.xml  { head :ok }
#    end
#  end
end
