class LogItemsController < ApplicationController
  def index
    if params[:type].blank? || params[:type]=="all"
      @logs = current_user.my_follow_log_items.paginate :page => params[:page]
    elsif params[:type]=="colleague"
      @logs = current_user.colleague_logs.paginate :page => params[:page]
    elsif params[:type]=="friend"
      @logs = current_user.friend_logs.paginate :page => params[:page]
    elsif params[:type]=="group"
      @logs = current_user.group_logs.paginate :page => params[:page]
    elsif params[:type]=="company"
      @logs = current_user.following_company_logs.paginate :page => params[:page]
    end
    respond_to do |format|
      format.html #
      format.js{  }
    end
  end

end
