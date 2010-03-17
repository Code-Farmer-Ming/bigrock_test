class MembersController < ApplicationController
  before_filter :check_login?
  def index
    @group = Group.find_by_id(params[:group_id])
    @page_title = "#{@group.name}小组 成员管理"
    if @group
      @normal_members = @group.normal_members.paginate :joins=>"join resumes on users.id = resumes.user_id ",
        :conditions=>[" resumes.user_name like ?",'%'+(params[:search] || '')+'%'],
        :page => params[:page] 
    end
  end

  def destroy
    @group = Group.find(params[:group_id])
    if (@group.roots.size==1 && @group.roots.exists?(["users.id=?",params[:id]]))
      flash.now[:notice] = "现在不能退出小组,小组必须有一个组长，在指定其他人为组长后才能退出。"
      render :update do |page|
        page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
      end
    else
      if @group.is_manager_member?(current_user) &&
          Member.destroy_all(["user_id=? and group_id=?",params[:id],@group])
        render :update do |page|
          page.visual_effect :fade, "group_member_user_#{params[:id]}", :duration => 0.5
          page.delay(0.5) do
            page["group_member_user_#{params[:id]}"].remove
          end
        end
      else
        flash.now[:error] = "删除出错!"
        render :update do |page|
          page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
        end
      end
    end

  end
  #升为 组长
  def to_root
    @group = Group.find(params[:group_id])
    if (@group.roots.size<2)
      if @group.is_root?(current_user) &&
          (memb = @group.members.find_by_user_id(params[:id])) &&
          (memb.update_attribute("member_type", Member::MEMBER_TYPES[0]))
        render :update do |page|
          page.visual_effect :fade, "group_member_user_#{params[:id]}", :duration => 0.5
          page.delay(0.5) do
            page["group_member_user_#{params[:id]}"].remove
            page.insert_html :bottom ,"group_root_list",render(:partial=>"members/member",:object=>@group.all_members.find(params[:id]))
          end
        end
        return
      else
        flash.now[:error] = "操作错误!#{$!}"
      end
    else
      flash.now[:notice] = "小组最多只能有2个组长。"
    end
    render :update do |page|
      page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
    end
  end
  
  #设为 管理员
  #params[:id] 为 user
  def to_manager
    @group = Group.find(params[:group_id])
    if (@group.roots.size==1 && @group.roots.exists?(["users.id=?",params[:id]]))
      flash.now[:notice] = "现在不能退出小组,小组必须有一个组长，在指定其他人为组长后才能退出。"
    else
      if (@group.managers.size<10)
        if @group.is_root?(current_user) &&
            (memb = @group.members.find_by_user_id(params[:id])) &&
            (memb.update_attribute("member_type", Member::MEMBER_TYPES[1]))
          render :update do |page|
            page.visual_effect :fade, "group_member_user_#{params[:id]}", :duration => 0.5
            page.delay(0.5) do
              page["group_member_user_#{params[:id]}"].remove
              page.insert_html :bottom ,"group_manager_list",render(:partial=>"members/member",:object=>@group.all_members.find(params[:id]))
            end
          end
          return
        else
          flash.now[:error] = "操作错误!#{$!}"
        end
      else
        flash.now[:notice] = "小组最多只能有10个管理员。"
      end
    end
    render :update do |page|
      page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
    end
  end
  
  #设为普通 成员
  def to_normal
    @group = Group.find(params[:group_id])
    if (@group.roots.size==1 && @group.roots.exists?(["users.id=?",params[:id]]))
      flash.now[:notice] = "现在不能退出小组,小组必须有一个组长，在指定其他人为组长后才能退出。"
    else
      if @group.is_root?(current_user) &&
          (memb = @group.members.find_by_user_id(params[:id])) &&
          (memb.update_attribute("member_type", Member::MEMBER_TYPES[2]))
        render :update do |page|
          page.visual_effect :fade, "group_member_user_#{params[:id]}", :duration => 0.5
          page.delay(0.5) do
            page["group_member_user_#{params[:id]}"].remove
            page.insert_html :bottom ,"group_member_list",render(:partial=>"members/member",:object=>@group.all_members.find(params[:id]))
          end
        end
        return
      else
        flash.now[:error] = "操作错误!#{$!}"
      end
    end
    render :update do |page|
      page["flash_msg"].replace_html render(:partial=>"comm_partial/flash_msg")
    end
  end



end
