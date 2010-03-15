class AddGroupApplicationsController < ApplicationController
  #TODO 添加 批量操作 能批量加入或批量忽略
  def index
    @page_title ="加入小组申请列表"
    @group = Group.find_by_id(params[:group_id])
    if @group
      @add_applications = @group.add_applications.paginate :page => params[:page]
    else
      redirect_to groups_path()
    end
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
    @group = Group.find_by_id(params[:group_id])
    if @group
      add_app = @group.add_applications.find_by_id(params[:id])
      if add_app
        if !@group.is_member?(add_app.applicant)
          (@group.all_members << add_app.applicant)
        end
        add_app.destroy
        flash[:success] = "接受了申请！"
      else
        flash[:error] = "产生错误！"
      end
      redirect_to :action=>"index"  , :page => params[:page]
    else
      redirect_to groups_path()
    end
  end

  def destroy
    @group = Group.find_by_id(params[:group_id])
    if @group
      if  ! (@group.add_applications.find_by_id(params[:id]) && @group.add_applications.find_by_id(params[:id]).destroy)
        flash[:error] = "产生错误！"
      end
      redirect_to :action=>"index"  , :page => params[:page]
    else
      redirect_to groups_path()
    end
  end

end
