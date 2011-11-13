class ApplyColleaguesController < ApplicationController

  def create
    @add_application = current_user.apply_colleagues.build(params[:apply_colleague])
    @user = User.find(params[:user_id])
    @add_application.respondent_id = params[:user_id]
    render :update do |page|
      if  @add_application.save
        flash.now[:success] = '已经申请,请等待回应吧。'
        page[dom_id(@user,"operation")].replace_html render(:partial=>"users/operation",:object=> @user)
        page[dom_id(@user,"operation")].visual_effect(:highlight)
        page["flash_msg"].replace_html(render(:partial=>"comm_partial/flash_msg"))
        page<<"Lightbox.close()"
      end
    end
  end

  def new
    @add_application  = ApplyColleague.new()
  end

  def index
    @page_title="同事申请列表"
    @applies = current_user.by_apply_colleagues.paginate :page => params[:page]
  end

  def destroy
    @apply = current_user.by_apply_colleagues.find(params[:id])
    render :update do |page|
      if @apply.destroy
        page[dom_id(@apply,"operation")].replace_html "已忽略"
        page[dom_id(@apply,"operation")].visual_effect(:highlight)
      end
    end
  end

  def accept
    @apply = current_user.by_apply_colleagues.find(params[:id])
    render :update do |page|
      if  @apply.accept
        page[dom_id(@apply,"operation")].replace_html "你们已成为同事"
        page[dom_id(@apply,"operation")].visual_effect(:highlight)
      end
    end
  end
  
end
