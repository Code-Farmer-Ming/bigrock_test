class ColleaguesController < ApplicationController
  before_filter :check_login?
  # GET /colleagues
  # GET /colleagues.xml
  def index
    @user = User.find(params[:user_id])
    @page_title ="#{@user.name} 同事信息列表"
    if params[:type]=="undetermined"
      if !params[:pass_id]
        @colleeagus=@user.need_confirm_colleague_users.paginate :page => params[:page]
      else
        @pass =@user.passes.find(params[:pass_id])
        @colleeagus =@pass.need_confirm_colleague_users.paginate :page => params[:page]
      end
    else
      if !params[:pass_id]
        @colleeagus=@user.colleague_users.paginate :page => params[:page]
      else
        @pass =@user.passes.find(params[:pass_id])
        @colleeagus =@pass.colleague_users.paginate :page => params[:page]
      end
    end
  end
 
  #取消
  def cancel
    @user = current_user.colleague_users.find(params[:user_id])
    current_user.colleagues.find_all_by_colleague_id(params[:user_id]).each do |colleague|
      colleague.not_colleague
    end
    @user.colleagues.find_all_by_colleague_id(current_user.id).each do |colleague|
      colleague.not_colleague
    end
    render :update do |page|
      page[dom_id(@user,"operation")].replace_html render(:partial=>"users/operation",:object=>@user)
      page[dom_id(@user,"operation")].visual_effect(:highlight)
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
