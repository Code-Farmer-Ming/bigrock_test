class AddGroupApplicationsController < ApplicationController
  before_filter :check_login?
  before_filter :find_group_and_author_check, :except => [:apply]
  #TODO 添加 批量操作 能批量加入或批量忽略
  def index
    @page_title ="加入小组申请列表"
    @add_applications = @group.add_applications.paginate :page => params[:page]
  end
  #申请加入小组
  def apply
    @add_application = AddGroupApplication.new(params[:add_group_application])
    if request.post?
      group = Group.find(params[:group_id])
      @add_application.applicant = current_user.get_account(params[:alias])
      if group.add_applications <<  @add_application
        render :update do |page|
          page[dom_id(group,"operation")].replace_html render(:partial=>"groups/operation",:object=> group)
          page<<"Lightbox.close()"
        end
      end
    end
  end

  def accept
    add_app = @group.add_applications.find_by_id(params[:id])
    if add_app && @group.add_to_member(add_app.applicant)
      add_app.destroy
      flash[:success] = "接受了申请！"
    else
      flash[:error] = "产生错误！"
    end
    redirect_to :action=>"index"  , :page => params[:page]

  end

  def destroy
    if  ! (@group.add_applications.find_by_id(params[:id]) && @group.add_applications.find_by_id(params[:id]).destroy)
      flash[:error] = "产生错误！"
    end
    redirect_to :action=>"index"  , :page => params[:page]
  end
  
  protected
  #查找小组 并检查授权设置
  def find_group_and_author_check
    @group = Group.find(params[:group_id])
    if not @group.is_manager_member?(current_user)
      flash[:error] = @group.errors.full_messages.to_s
      redirect_to @group
    end

  end
end
