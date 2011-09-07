class LogItemsController < ApplicationController
  def index
    if params[:type].blank? || params[:type]=="all"
      @logs = current_user.my_follow_log_items.paginate :page => params[:page]
    else
      @logs = current_user.my_follow_log_items.paginate_by_owner_type params[:type], :page => params[:page]
    end
    respond_to do |format|
      format.html #
      format.js{  }
    end
  end

end
