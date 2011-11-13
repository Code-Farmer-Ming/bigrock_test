class FriendsController < ApplicationController
 
  def index
    @page_title = "好友列表"
    @user = User.find(params[:user_id])
    @friend_users = @user.friend_users.paginate :page=>params[:page]
  end
  
  #取消好友
  def cancel
    @user = User.find(params[:user_id])
    current_user.cancel_friend(@user)
    render :update do |page|
      page[dom_id(@user,"operation")].replace_html render(:partial=>"users/operation",:object=>@user)
      page[dom_id(@user,"operation")].visual_effect(:highlight)
    end
  end

end
