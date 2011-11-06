class FriendsController < ApplicationController
 
  def index
    @page_title = "好友列表"
    @user = User.find(params[:user_id])
    @friend_users = @user.friend_users.paginate :page=>params[:page]
  end

end
