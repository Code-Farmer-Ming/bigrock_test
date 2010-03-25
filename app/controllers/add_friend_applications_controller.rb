class AddFriendApplicationsController < ApplicationController
  before_filter :check_login?
  before_filter :find_apply, :only => [:accept, :destroy]

  def index
    @page_title ="好友申请"
    @add_friend_applications = current_user.add_friend_applications.paginate :page => params[:page]
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def accept
    current_user.add_friend(@apply.applicant)  unless params[:commit]!="接受并加其为好友"
    @apply.accept(current_user)
    flash[:success] = "添加成功！"
    redirect_to :action=>"index"  , :page => params[:page]
  end

  def destroy
    @apply.destroy
    flash[:success] = "已经忽略！"
    redirect_to :action=>"index"  , :page => params[:page]
  end
  #TODO 需要重新修改
  #申请加为好友
  def apply
    @add_friend = AddFriendApplication.new(params[:add_friend_application])
    if !request.post?
      @respondent = User.find(params[:respondent_id])
      #      @add_friend.respondent = @respondent
      @add_friend.respondent_id = params[:respondent_id]
    else
      @add_friend.applicant = current_user
      if @add_friend.save()
        render :update do |page|
          page["user_operation"].replace_html render(:partial=>"users/operation",:object=> @add_friend.respondent)
          page<<"Lightbox.close()"
        end
      end
    end
  end

  protected
  
  def find_apply
    @apply = current_user.add_friend_applications.find(params[:id])
  end
end
