class AddFriendApplicationsController < ApplicationController
  before_filter :check_login?
  def index
    @page_title ="好友申请"
    @add_friend_applications = current_user.add_friend_applications.paginate :page => params[:page]
    respond_to do |format|
      format.html # index.html.erb
    end
  end

  def accept
    @apply = current_user.add_friend_applications.find(params[:id])
    if params[:commit] =="接受并加其为好友"
      if !current_user.friends_user.exists?(@apply.applicant)
        current_user.friends_user << @apply.applicant
      end
    end
    if !@apply.applicant.friends_user.exists?(current_user)
      @apply.applicant.friends_user << current_user
    end
    @apply.destroy
    flash[:success] = "添加成功！"
    
    redirect_to :action=>"index"  , :page => params[:page]
  end

  def destroy
    @apply = current_user.add_friend_applications.find(params[:id])
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

end
