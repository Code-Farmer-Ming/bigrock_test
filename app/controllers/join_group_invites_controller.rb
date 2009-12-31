class JoinGroupInvitesController < ApplicationController
  def index
    @page_title ="加入小组邀请"
    @invites =  current_user.join_group_invites.paginate :page => params[:page]
  end

  def accept
    @apply = current_user.join_group_invites.find(params[:id])
    if @apply.applicant.is_member?(current_user) && @apply.destroy
      flash[:success] = "加入成功！"
    else
      if  @apply.applicant.all_members << current_user && @apply.destroy
        flash[:success] = "加入成功！"
      else
        flash[:success] = "加人失败！"
      end
    end
    redirect_to :action=>"index"  , :page => params[:page]
  end

  def destroy
    @apply = current_user.join_group_invites.find(params[:id])
    @apply.destroy
    flash[:success] = "已经忽略！"
    redirect_to :action=>"index"  , :page => params[:page]
  end

end
