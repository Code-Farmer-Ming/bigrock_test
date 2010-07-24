class MembersController < ApplicationController
  before_filter :check_login?
  before_filter :find_group,:only=>[:index,:destroy,:to_root,:to_manager,:to_normal]
  before_filter :find_user,:only=>[:destroy,:to_root,:to_manager,:to_normal]
  
  def index
    @page_title = "#{@group.name}小组 成员管理"
    @normal_members = @group.normal_members.paginate :joins=>"join resumes on users.id = resumes.user_id ",
      :conditions=>[" resumes.user_name like ?",'%'+(params[:search] || '')+'%'],
      :page => params[:page]
  end

  def destroy
    if @group.is_manager_member?(current_user) && @group.remove_member(@user)
      render :update do |page|
        page.visual_effect :fade, "group_member_user_#{params[:id]}", :duration => 0.5
        page.delay(0.5) do
          page["group_member_user_#{params[:id]}"].remove
        end
      end
    else
      flash.now[:error] =  @group.errors.full_messages.to_s
      render :update do |page|
        page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
      end
    end
  end
  #升为 组长
  def to_root
    if @group.is_root?(current_user) && @group.to_root(@user)
      render :update do |page|
        page.visual_effect :fade, "group_member_user_#{params[:id]}", :duration => 0.5
        page.delay(0.5) do
          page["group_member_user_#{params[:id]}"].remove
          page.insert_html :bottom ,"group_root_list",render(:partial=>"members/root_member",:object=>@user,:locals=>{:group=>@group})
        end
      end
    else
      flash.now[:error] = @group.errors.full_messages.to_s
      render :update do |page|
        page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
      end
    end
  end
  #设为 管理员
  #params[:id] 为 user
  def to_manager
    if @group.is_root?(current_user) && @group.to_manager(@user)
      render :update do |page|
        page.visual_effect :fade, "group_member_user_#{params[:id]}", :duration => 0.5
        page.delay(0.5) do
          page["group_member_user_#{params[:id]}"].remove
          page.insert_html :bottom ,"group_manager_list",render(:partial=>"members/manager_member",:object=>@user,:locals=>{:group=>@group})
        end
      end
    else
      flash.now[:error] = @group.errors.full_messages.to_s
      render :update do |page|
        page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
      end
    end
  end
  
  #设为普通 成员
  def to_normal
    if @group.is_root?(current_user) &&   @group.to_normal(@user)
      render :update do |page|
        page.visual_effect :fade, "group_member_user_#{params[:id]}", :duration => 0.5
        page.delay(0.5) do
          page["group_member_user_#{params[:id]}"].remove
          page.insert_html :bottom ,"group_member_list",render(:partial=>"members/normal_member",:object=>@user,:locals=>{:group=>@group})
        end
      end
    else
      flash.now[:error] =  @group.errors.full_messages.to_s
      render :update do |page|
        page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
      end
    end
  end

  protected

  def find_group
    @group = Group.find(params[:group_id])
  end
  def find_user
    @user = User.find(params[:id])
  end
end
