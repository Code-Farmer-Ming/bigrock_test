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
    @apply.accept()
    render :update do |page|
      page[dom_id(@apply,"operation")].replace_html  "你们是朋友啦!"
      page[dom_id(@apply,"operation")].visual_effect(:highlight)
    end
  end

  def destroy
    @apply.destroy
    render :update do |page|
      page[dom_id(@apply,"operation")].replace_html  "已经忽略"
      page[dom_id(@apply,"operation")].visual_effect(:highlight)
    end
  end

  def new
    @add_friend = AddFriendApplication.new()
  end

  def create
    @add_friend = AddFriendApplication.new(params[:add_friend_application])
    @add_friend.respondent_id = params[:user_id]
    if  current_user.my_add_friend_applications << @add_friend
      render :update do |page|
        page[dom_id(@add_friend.respondent,"operation")].replace_html render(:partial=>"users/operation",:object=> @add_friend.respondent)
        page[dom_id(@add_friend.respondent,"operation")].visual_effect(:highlight)
        page<<"Lightbox.close()"
      end
    end
  end

  protected
  
  def find_apply
    @apply = current_user.add_friend_applications.find(params[:id])
  end
end